defmodule MyAshBlog.Blog.CommentTest do
  use ExUnit.Case

  alias MyAshBlog.Blog.Comment

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    :ok
  end

  test "criar um comentário" do
    changeset =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Test comment", author: "Author Name"})

    assert {:ok, comment} = Ash.create(changeset)
    assert comment.content == "Test comment"
    assert comment.author == "Author Name"
  end

  test "buscar um comentário pelo id" do
    changeset =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Test comment", author: "Author Name"})

    {:ok, comment} = Ash.create(changeset)

    query = Comment |> Ash.Query.for_read(:by_id, %{id: comment.id})
    assert {:ok, fetched_comment} = Ash.read_one(query)
    assert fetched_comment.content == "Test comment"
    assert fetched_comment.author == "Author Name"
  end

  test "atualizar um comentário" do
    changeset =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Test comment", author: "Author Name"})

    {:ok, comment} = Ash.create(changeset)

    update_changeset =
      comment
      |> Ash.Changeset.for_update(:update, %{content: "Updated comment", author: "Updated Author"})

    assert {:ok, updated_comment} = Ash.update(update_changeset)
    assert updated_comment.content == "Updated comment"
    assert updated_comment.author == "Updated Author"
  end

  test "deletar um comentário" do
    changeset =
      Comment
      |> Ash.Changeset.for_create(:create, %{content: "Test comment", author: "Author Name"})

    {:ok, comment} = Ash.create(changeset)

    assert :ok = Ash.destroy(comment)

    query = Comment |> Ash.Query.for_read(:by_id, %{id: comment.id})
    assert {:ok, nil} = Ash.read_one(query)
  end
end
