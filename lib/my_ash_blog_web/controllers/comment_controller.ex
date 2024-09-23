defmodule MyAshBlogWeb.CommentController do
  use MyAshBlogWeb, :controller

  alias MyAshBlog.Blog

  # GET /api/comments
  def index(conn, _params) do
    comments = Blog.Comment |> Ash.Query.for_read(:read) |> Ash.read!()

    conn
    |> put_view(MyAshBlogWeb.CommentJSON)
    |> render(:index, comments: comments)
  end

  # GET /api/comments/:id
  def show(conn, %{"id" => id}) do
    case Blog.Comment |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, comment} ->
        conn
        |> put_view(MyAshBlogWeb.CommentJSON)
        |> render(:show, comment: comment)

      _ ->
        send_resp(conn, :not_found, "Comment not found")
    end
  end

  # POST /api/comments
  def create(conn, %{"comment" => comment_params}) do
    changeset = Blog.Comment |> Ash.Changeset.for_create(:create, comment_params)

    case Ash.create(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(:created)
        |> put_view(MyAshBlogWeb.CommentJSON)
        |> render(:show, comment: comment)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # PUT /api/comments/:id
  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Blog.Comment |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one!()

    changeset = comment |> Ash.Changeset.for_update(:update, comment_params)

    case Ash.update(changeset) do
      {:ok, comment} ->
        conn
        |> put_view(MyAshBlogWeb.CommentJSON)
        |> render(:show, comment: comment)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # DELETE /api/comments/:id
  def delete(conn, %{"id" => id}) do
    case Blog.Comment |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, nil} ->
        send_resp(conn, :not_found, "Comment not found")

      {:ok, comment} ->
        case Ash.destroy(comment) do
          :ok ->
            send_resp(conn, :ok, "Comment deleted")

          {:ok, _comment} ->
            send_resp(conn, :ok, "Comment deleted")

          {:error, _reason} ->
            send_resp(conn, :unprocessable_entity, "Error deleting comment")
        end

      {:error, _reason} ->
        send_resp(conn, :not_found, "Comment not found")
    end
  end
end
