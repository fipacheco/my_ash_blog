defmodule MyAshBlogWeb.PostController do
  use MyAshBlogWeb, :controller

  alias MyAshBlog.Blog

  # GET /api/posts
  def index(conn, _params) do
    posts = Blog.Post |> Ash.Query.for_read(:read) |> Ash.read!()

    conn
    |> put_view(MyAshBlogWeb.PostJSON)
    |> render(:index, posts: posts)
  end

  # GET /api/posts/:id
  def show(conn, %{"id" => id}) do
    case Blog.Post |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, post} ->
        conn
        |> put_view(MyAshBlogWeb.PostJSON)
        |> render(:show, post: post)

      _ ->
        send_resp(conn, :not_found, "Post not found")
    end
  end

  # POST /api/posts
  def create(conn, %{"post" => post_params}) do
    changeset = Blog.Post |> Ash.Changeset.for_create(:create, post_params)

    case Ash.create(changeset) do
      {:ok, post} ->
        conn
        |> put_status(:created)
        |> put_view(MyAshBlogWeb.PostJSON)
        |> render(:show, post: post)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # PUT /api/posts/:id
  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Blog.Post |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one!()

    changeset = post |> Ash.Changeset.for_update(:update, post_params)

    case Ash.update(changeset) do
      {:ok, post} ->
        conn
        |> put_view(MyAshBlogWeb.PostJSON)
        |> render(:show, post: post)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # DELETE /api/posts/:id
  def delete(conn, %{"id" => id}) do
    case Blog.Post |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, nil} ->
        send_resp(conn, :not_found, "Post not found")

      {:ok, post} ->
        case Ash.destroy(post) do
          :ok ->
            send_resp(conn, :ok, "Post deleted")

          {:ok, _post} ->
            send_resp(conn, :ok, "Post deleted")

          {:error, _reason} ->
            send_resp(conn, :unprocessable_entity, "Error deleting post")
        end

        {:error, _reason} ->
          send_resp(conn, :not_found, "Post not found")
      end
    end
  end
