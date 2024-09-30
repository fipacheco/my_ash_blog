defmodule MyAshBlog.Blog.PostTest do
  use ExUnit.Case

  alias MyAshBlog.Blog.Post

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    :ok
  end

  test "criar um post" do
    changeset =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Test Post", content: "This is a test post content"})

    assert {:ok, post} = Ash.create(changeset)
    assert post.title == "Test Post"
    assert post.content == "This is a test post content"
  end

  test "buscar um post pelo id" do
    changeset =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Test Post", content: "This is a test post content"})

    {:ok, post} = Ash.create(changeset)

    query = Post |> Ash.Query.for_read(:by_id, %{id: post.id})
    assert {:ok, fetched_post} = Ash.read_one(query)
    assert fetched_post.title == "Test Post"
    assert fetched_post.content == "This is a test post content"
  end

  test "atualizar um post" do
    changeset =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Test Post", content: "This is a test post content"})

    {:ok, post} = Ash.create(changeset)

    update_changeset =
      post
      |> Ash.Changeset.for_update(:update, %{title: "Updated Title", content: "Updated content"})

    assert {:ok, updated_post} = Ash.update(update_changeset)
    assert updated_post.title == "Updated Title"
    assert updated_post.content == "Updated content"
  end

  test "deletar um post" do
    changeset =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "Test Post", content: "This is a test post content"})

    {:ok, post} = Ash.create(changeset)

    assert :ok = Ash.destroy(post)

    query = Post |> Ash.Query.for_read(:by_id, %{id: post.id})
    assert {:ok, nil} = Ash.read_one(query)
  end
end
