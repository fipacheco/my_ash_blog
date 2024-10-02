defmodule MyAshBlog.Blog.AllAssociationsTest do
  use ExUnit.Case

  alias MyAshBlog.Blog.{Author, Post, Comment, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyAshBlog.Repo)
    :ok
  end

  test "associar autor com post, post com comentário, e comentário com usuário" do
    # Cria um autor
    changeset_author =
      Author
      |> Ash.Changeset.for_create(:create, %{
        name: "Author Name",
        email: "author@example.com"
      })

    {:ok, author} = Ash.create(changeset_author)

    # Cria um post associado ao autor
    changeset_post =
      Post
      |> Ash.Changeset.for_create(:create, %{
        title: "Post Title",
        content: "Post Content",
        author_id: author.id
      })

    {:ok, post} = Ash.create(changeset_post)

    # Verifica a associação entre o post e o autor
    assert post.author_id == author.id

    # Cria um usuário
    changeset_user =
      User
      |> Ash.Changeset.for_create(:create, %{
        username: "TestUser",
        email: "testuser@example.com",
        password: "testpassword"
      })

    {:ok, user} = Ash.create(changeset_user)

    # Verifica se o usuário foi criado corretamente
    assert user.username == "TestUser"

    # Cria um comentário associado ao post e ao usuário
    changeset_comment =
      Comment
      |> Ash.Changeset.for_create(:create, %{
        content: "This is a comment",
        author: "Comment Author",
        post_id: post.id,
        user_id: user.id
      })

    {:ok, comment} = Ash.create(changeset_comment)

    # Verifica se o comentário está associado corretamente ao post e ao usuário
    assert comment.post_id == post.id
    assert comment.user_id == user.id

    # Confirma que o autor, post, comentário e usuário foram criados e associados corretamente
    assert comment.author == "Comment Author"
    assert comment.content == "This is a comment"
  end
end
