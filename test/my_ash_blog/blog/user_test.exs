defmodule MyAshBlog.Blog.UserTest do
  use ExUnit.Case

  alias MyAshBlog.Blog.User

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    :ok
  end

  test "criar um usuário com hash de senha" do
    changeset =
      User
      |> Ash.Changeset.for_create(:create, %{
        username: "TestUser",
        email: "user@example.com",
        password: "senha_segura"
      })

    assert {:ok, user} = Ash.create(changeset)
    assert user.username == "TestUser"
    assert user.email == "user@example.com"
    assert Bcrypt.verify_pass("senha_segura", user.password)
  end

  test "buscar um usuário pelo id" do
    changeset =
      User
      |> Ash.Changeset.for_create(:create, %{
        username: "TestUser",
        email: "user@example.com",
        password: "senha_segura"
      })

    {:ok, user} = Ash.create(changeset)

    query = User |> Ash.Query.for_read(:by_id, %{id: user.id})
    assert {:ok, fetched_user} = Ash.read_one(query)
    assert fetched_user.email == "user@example.com"
    assert fetched_user.username == "TestUser"
  end

  test "atualizar o nome e email de um usuário" do
    # Cria um usuário
    changeset =
      User
      |> Ash.Changeset.for_create(:create, %{
        username: "TestUser",
        email: "user@example.com",
        password: "senha_segura"
      })

    {:ok, user} = Ash.create(changeset)

    # Usa o usuário criado para fazer a atualização
    update_changeset =
      user
      |> Ash.Changeset.for_update(:update, %{
        username: "UpdatedUser",
        email: "updated@example.com"
      })

    assert {:ok, updated_user} = Ash.update(update_changeset)
    assert updated_user.username == "UpdatedUser"
    assert updated_user.email == "updated@example.com"
  end

  test "atualizar a senha de um usuário" do
    # Cria um usuário
    changeset =
      User
      |> Ash.Changeset.for_create(:create, %{
        username: "TestUser",
        email: "user@example.com",
        password: "senha_segura"
      })

    {:ok, user} = Ash.create(changeset)

    # Usa o usuário criado para atualizar a senha
    update_changeset =
      user
      |> Ash.Changeset.for_update(:update, %{
        password: "nova_senha_segura"
      })

    assert {:ok, updated_user} = Ash.update(update_changeset)
    assert Bcrypt.verify_pass("nova_senha_segura", updated_user.password)
  end

  test "deletar um usuário" do
    # Cria um usuário
    changeset =
      User
      |> Ash.Changeset.for_create(:create, %{
        username: "TestUser",
        email: "user@example.com",
        password: "senha_segura"
      })

    {:ok, user} = Ash.create(changeset)

    # Verifica a remoção do usuário
    assert :ok = Ash.destroy(user)

    query = User |> Ash.Query.for_read(:by_id, %{id: user.id})
    assert {:ok, nil} = Ash.read_one(query)
  end
end
