defmodule MyAshBlog.Blog.UserPolicyTest do
  use ExUnit.Case, async: false
  alias MyAshBlog.Blog.User
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
    hashed_password = Argon2.hash_pwd_salt("password123") # Assegure-se de que o Argon2 está configurado

    %MyAshBlog.Blog.User{
      email: unique_email,
      hashed_password: hashed_password,
      username: "admin_#{System.unique_integer([:positive])}",
      role: :admin,
      is_author: true
    }
    |> Repo.insert!()
  end

  # Função para criar um usuário regular utilizando a ação padrão :register_with_password
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

    # Espera-se um erro de autorização
    assert {:error, %Ash.Error.Forbidden{}} = result
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

    {:ok, _deleted_user} =
      user
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user)
      |> Ash.destroy()

    # Verificar se o usuário não existe mais
    result =
      User
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(id == ^user.id)
      |> Ash.read()

    # Espera-se um erro de autorização, pois o usuário não existe mais
    assert {:error, %Ash.Error.Forbidden{}} = result
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
    {:ok, updated_user} =
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

  # Teste para verificar se usuários comuns não podem atualizar role
  test "Usuários comuns não podem atualizar role", %{admin_user: admin_user} do
    user = build_regular_user()

    # Tentativa de atualizar role via :admin_update (deve falhar por autorização)
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
end
