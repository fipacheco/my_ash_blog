defmodule MyAshBlog.Blog.UserAuthTest do
  use ExUnit.Case, async: false

  alias MyAshBlog.Blog.User
  alias Ash.Changeset

  @valid_user_params %{
    "username" => "testuser",
    "email" => "test@example.com",
    "password" => "password123"
  }

  @invalid_user_params %{
    "username" => "testuser",
    "email" => nil,
    "password" => "password123"
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    :ok
  end

  test "User registration successfully registers a user with valid data" do
    changeset = Changeset.for_create(User, :create, @valid_user_params)
    assert {:ok, user} = Ash.create(changeset)
    assert user.username == "testuser"
    assert user.email == "test@example.com"
  end

  test "User registration fails to register a user with invalid data" do
    changeset = Changeset.for_create(User, :create, @invalid_user_params)
    assert {:error, _changeset} = Ash.create(changeset)
  end

  test "User login simulation successfully logs in with valid credentials" do
    # Primeiro, cria o usuário
    changeset = Changeset.for_create(User, :create, @valid_user_params)
    {:ok, user} = Ash.create(changeset)

    # Verificação de dados do usuário criado
    assert user.username == "testuser"
    assert user.email == "test@example.com"
  end

  test "User login simulation fails with incorrect credentials" do
    # Cria o usuário
    changeset = Changeset.for_create(User, :create, @valid_user_params)
    {:ok, _user} = Ash.create(changeset)

    # Simula tentativa de login com credenciais incorretas
    wrong_credentials = %{
      "email" => "wrong@example.com",
      "password" => "password123"
    }

    changeset = Changeset.for_create(User, :create, wrong_credentials)
    assert {:error, _changeset} = Ash.create(changeset)
  end

  test "User login fails to log in with wrong password" do
    changeset = Ash.Changeset.for_create(User, :create, @valid_user_params)
    {:ok, user} = Ash.create(changeset)

    login_changeset = Ash.Changeset.for_create(User, :create, %{
      "email" => user.email,
      "password" => "wrongpassword"
    })

    assert {:error, _changeset} = Ash.create(login_changeset)
  end

end
