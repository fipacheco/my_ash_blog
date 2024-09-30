defmodule MyAshBlog.Blog.AuthorTest do
  use ExUnit.Case, async: true

  alias MyAshBlog.Blog.Author
  alias Ash.Changeset
  alias Ash.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    :ok
  end

  test "criar um autor" do
    changeset =
      Author
      |> Changeset.for_create(:create, %{name: "Test Author", email: "author@example.com"})

    assert {:ok, author} = Ash.create(changeset)
    assert author.name == "Test Author"
    assert author.email == "author@example.com"
  end

  test "atualizar o nome e email de um autor" do
    changeset =
      Author
      |> Changeset.for_create(:create, %{name: "Old Author", email: "oldauthor@example.com"})

    {:ok, author} = Ash.create(changeset)

    update_changeset =
      author
      |> Changeset.for_update(:update, %{name: "Updated Author", email: "updated@example.com"})

    assert {:ok, updated_author} = Ash.update(update_changeset)
    assert updated_author.name == "Updated Author"
    assert updated_author.email == "updated@example.com"
  end

  test "buscar um autor pelo ID" do
    changeset =
      Author
      |> Changeset.for_create(:create, %{name: "Test Author", email: "author@example.com"})

    {:ok, author} = Ash.create(changeset)

    query = Author |> Query.for_read(:by_id, %{id: author.id})
    assert {:ok, fetched_author} = Ash.read_one(query)
    assert fetched_author.email == "author@example.com"
  end

  test "tentar buscar um autor com ID inválido" do
    query = Author |> Query.for_read(:by_id, %{id: "invalid-id"})
    assert {:error, _reason} = Ash.read_one(query)
  end

  test "deletar um autor" do
    changeset =
      Author
      |> Changeset.for_create(:create, %{name: "Author To Delete", email: "delete@example.com"})

    {:ok, author} = Ash.create(changeset)

    assert :ok = Ash.destroy(author)

    query = Author |> Query.for_read(:by_id, %{id: author.id})

    assert {:ok, nil} = Ash.read_one(query)
  end

end
