defmodule MyAshBlog.Blog.NewPoliciesTest do
  use ExUnit.Case, async: false
  alias MyAshBlog.Blog.{User, Post, Comment}
  alias MyAshBlog.Repo
  require Ash.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MyAshBlog.Repo, {:shared, self()})

    # Criar um usuário administrador e incluí-lo no contexto de teste
    admin_user = create_admin_user()
    {:ok, admin_user: admin_user}
  end

  # Função privada para criar um usuário administrador diretamente via Ecto
  defp create_admin_user do
    unique_email = "admin_#{System.unique_integer([:positive])}@example.com"
    hashed_password = Argon2.hash_pwd_salt("password123")

    %MyAshBlog.Blog.User{
      email: unique_email,
      hashed_password: hashed_password,
      username: "admin_#{System.unique_integer([:positive])}",
      role: :admin,
      is_author: true
    }
    |> Repo.insert!()
  end

  # Função para criar um usuário regular utilizando a ação padrão :create
  defp build_regular_user do
    unique_email = "user_#{System.unique_integer([:positive])}@example.com"

    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:create, %{
        email: unique_email,
        password: "password123",
        password_confirmation: "password123"
      })
      |> Ash.create()

    # Atualizar para definir o username
    {:ok, user} =
      user
      |> Ash.Changeset.for_update(:update, %{
        username: "user_#{System.unique_integer([:positive])}"
      }, actor: user)
      |> Ash.update()

    user
  end

  # Função para transformar usuário em autor
  defp update_user_role_to_author(user) do
    {:ok, updated_user} =
      user
      |> Ash.Changeset.for_update(:admin_update, %{is_author: true}, actor: user)
      |> Ash.update()

    updated_user
  end

  # Teste para verificar se usuários podem ler seus próprios dados
  test "Usuários podem ler seus próprios dados", %{admin_user: _admin_user} do
    user = build_regular_user()

    {:ok, result} =
      User
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(id == ^user.id)
      |> Ash.read()

    assert length(result) == 1
    assert Enum.at(result, 0).id == user.id
  end

  # Teste para verificar se usuários não podem ler dados de outros usuários
  test "Usuários não podem ler dados de outros usuários", %{admin_user: _admin_user} do
    user1 = build_regular_user()
    user2 = build_regular_user()

    result =
      User
      |> Ash.Query.for_read(:read, %{}, actor: user1)
      |> Ash.Query.filter(id == ^user2.id)
      |> Ash.read()

    ## Retorna ok para o erro
    assert {:ok, []} = result
  end

  # Teste para verificar se administradores podem ler dados de qualquer usuário
  test "Administradores podem ler dados de qualquer usuário", %{admin_user: admin_user} do
    user = build_regular_user()

    {:ok, result} =
      User
      |> Ash.Query.for_read(:read, %{}, actor: admin_user)
      |> Ash.Query.filter(id == ^user.id)
      |> Ash.read()

    assert length(result) == 1
    assert Enum.at(result, 0).id == user.id
  end

  # Teste para verificar se usuários podem atualizar seu próprio username
  test "Usuários podem atualizar seu próprio username", %{admin_user: _admin_user} do
    user = build_regular_user()

    {:ok, updated_user} =
      user
      |> Ash.Changeset.for_update(:update, %{username: "novo_username"}, actor: user)
      |> Ash.update()

    assert updated_user.username == "novo_username"
  end

  # Teste para verificar se usuários não podem atualizar dados de outros usuários
  test "Usuários não podem atualizar dados de outros usuários", %{admin_user: _admin_user} do
    user1 = build_regular_user()
    user2 = build_regular_user()

    changeset =
      user2
      |> Ash.Changeset.for_update(:update, %{username: "hacked_username"}, actor: user1)

    assert {:error, %Ash.Error.Forbidden{}} = Ash.update(changeset)
  end

  # Teste para verificar se administradores podem atualizar qualquer campo usando admin_update
  test "Administradores podem atualizar qualquer campo usando admin_update", %{admin_user: admin_user} do
    user = build_regular_user()

    {:ok, updated_user} =
      user
      |> Ash.Changeset.for_update(:admin_update, %{role: :admin, is_author: true}, actor: admin_user)
      |> Ash.update()

    assert updated_user.role == :admin
    assert updated_user.is_author == true
  end

  # Teste para verificar se usuários não podem mudar seu role para admin
  test "Usuários não podem mudar seu role para admin", %{admin_user: _admin_user} do
    user = build_regular_user()

    # Tentativa de atualização usando :admin_update (deve falhar por autorização)
    changeset =
      user
      |> Ash.Changeset.for_update(:admin_update, %{role: :admin}, actor: user)

    assert {:error, %Ash.Error.Forbidden{}} = Ash.update(changeset)

    # Tentativa de atualizar role via :update (deve falhar por campo inválido)
    changeset2 =
      user
      |> Ash.Changeset.for_update(:update, %{role: :admin}, actor: user)

    assert {:error, %Ash.Error.Invalid{}} = Ash.update(changeset2)
  end

  # Teste para verificar se usuários podem excluir sua própria conta
  test "Usuários podem excluir sua própria conta", %{admin_user: _admin_user} do
    user = build_regular_user()

    # Excluir a conta do usuário
    result =
      user
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user)
      |> Ash.destroy()

    # Ajuste na asserção para aceitar `:ok`
    assert result == :ok

    # Verificar se o usuário não existe mais
    result =
      User
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(id == ^user.id)
      |> Ash.read()

    # Espera-se um erro de autorização ou um retorno vazio, já que o usuário foi excluído
    assert {:ok, []} = result
  end

  # Teste para verificar se usuários não podem excluir contas de outros usuários
  test "Usuários não podem excluir contas de outros usuários", %{admin_user: _admin_user} do
    user1 = build_regular_user()
    user2 = build_regular_user()

    changeset =
      user2
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user1)

    assert {:error, %Ash.Error.Forbidden{}} = Ash.destroy(changeset)
  end

  # Teste para verificar se administradores podem excluir qualquer conta
  test "Administradores podem excluir qualquer conta", %{admin_user: admin_user} do
    user = build_regular_user()

    {:ok, _deleted_user} =
      user
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: admin_user)
      |> Ash.destroy()

    # Verificar se o usuário não existe mais
    {:ok, result} =
      User
      |> Ash.Query.for_read(:read, %{}, actor: admin_user)
      |> Ash.Query.filter(id == ^user.id)
      |> Ash.read()

    assert result == []
  end

  # Teste para verificar se apenas administradores podem definir is_author
  test "Apenas administradores podem definir is_author", %{admin_user: admin_user} do
    user = build_regular_user()

    # Administrador define is_author: true
    assert admin_user.role == :admin
    assert {:ok, updated_user} =
      user
      |> Ash.Changeset.for_update(:admin_update, %{is_author: true}, actor: admin_user)
      |> Ash.update()

    assert updated_user.is_author == true

    # Usuário comum tenta definir is_author (deve falhar)
    changeset =
      user
      |> Ash.Changeset.for_update(:admin_update, %{is_author: true}, actor: user)

    assert {:error, %Ash.Error.Forbidden{}} = Ash.update(changeset)
  end

  # Teste para verificar se autor pode criar um post
  test "Autor pode criar um post", %{admin_user: _admin_user} do
    author_user = build_regular_user()
    author_user = update_user_role_to_author(author_user)

    {:ok, post} =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Novo Post", body: "Conteúdo do Post"}, actor: author_user)
      |> Ash.create()

    assert post.title == "Novo Post"
    assert post.body == "Conteúdo do Post"
  end

  # Teste para verificar se apenas o autor pode deletar seu próprio post
  test "Apenas o autor pode deletar seu post", %{admin_user: _admin_user} do
    author_user = build_regular_user()
    author_user = update_user_role_to_author(author_user)

    {:ok, post} =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Post para deletar", body: "Conteúdo"}, actor: author_user)
      |> Ash.create()

    {:ok, _deleted_post} =
      post
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: author_user)
      |> Ash.destroy()

    assert_raise Ash.Error.NotFound, fn ->
      Post
      |> Ash.Query.filter(id == ^post.id)
      |> Ash.read!()
    end
  end

  # Teste para verificar se admins podem deletar qualquer comentário
  test "Administrador pode excluir qualquer comentário", %{admin_user: admin_user} do
    user = build_regular_user()

    # Criar um comentário como um usuário comum
    {:ok, comment} =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Comentário para ser excluído"}, actor: user)
      |> Ash.create()

    # Administrador exclui o comentário
    {:ok, _deleted_comment} =
      comment
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: admin_user)
      |> Ash.destroy()

    # Verifica se o comentário foi excluído com sucesso
    assert_raise Ash.Error.NotFound, fn ->
      Comment
      |> Ash.Query.filter(id == ^comment.id)
      |> Ash.read!()
    end
  end

  test "Usuário pode editar seu próprio comentário", %{admin_user: _admin_user} do
    user = build_regular_user()

    {:ok, comment} =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Comentário original"}, actor: user)
      |> Ash.create()

    {:ok, updated_comment} =
      comment
      |> Ash.Changeset.for_update(:update, %{content: "Comentário editado"}, actor: user)
      |> Ash.update()

    assert updated_comment.content == "Comentário editado"
  end

  test "Usuário pode excluir seu próprio comentário", %{admin_user: _admin_user} do
    user = build_regular_user()

    {:ok, post} =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Post para comentário", content: "Conteúdo"}, actor: user)
      |> Ash.create()

    {:ok, comment} =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Comentário para excluir", post_id: post.id}, actor: user)
      |> Ash.create()

    result =
      comment
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user)
      |> Ash.destroy()

    assert result == :ok

    assert_raise Ash.Error.NotFound, fn ->
      Comment
      |> Ash.Query.filter(id == ^comment.id)
      |> Ash.read!()
    end
  end
end
