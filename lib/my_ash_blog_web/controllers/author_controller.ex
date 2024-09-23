defmodule MyAshBlogWeb.AuthorController do
  use MyAshBlogWeb, :controller

  alias MyAshBlog.Blog


  # GET /api/authors
  def index(conn, _params) do
    authors = Blog.Author |> Ash.Query.for_read(:read) |> Ash.read!()

    conn
    |> put_view(MyAshBlogWeb.AuthorJSON)
    |> render(:index, authors: authors)
  end

  # GET /api/authors/:id
  def show(conn, %{"id" => id}) do
    case Blog.Author |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, author} ->
        conn
        |> put_view(MyAshBlogWeb.AuthorJSON)
        |> render(:show, author: author)

      _ ->
        send_resp(conn, :not_found, "Author not found")
    end
  end

  # POST /api/authors
  def create(conn, %{"author" => author_params}) do
    changeset = Blog.Author |> Ash.Changeset.for_create(:create, author_params)

    case Ash.create(changeset) do
      {:ok, author} ->
        conn
        |> put_status(:created)
        |> put_view(MyAshBlogWeb.AuthorJSON)
        |> render(:show, author: author)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # PUT /api/authors/:id
  def update(conn, %{"id" => id, "author" => author_params}) do
    author = Blog.Author |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one!()

    changeset = author |> Ash.Changeset.for_update(:update, author_params)

    case Ash.update(changeset) do
      {:ok, author} ->
        conn
        |> put_view(MyAshBlogWeb.AuthorJSON)
        |> render(:show, author: author)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # DELETE /api/authors/:id
  def delete(conn, %{"id" => id}) do
    case Blog.Author |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, nil} ->
        send_resp(conn, :not_found, "Author not found")

      {:ok, author} ->
        case Ash.destroy(author) do
          :ok ->
            send_resp(conn, :ok, "Author deleted")

          {:ok, _author} ->
            send_resp(conn, :ok, "Author deleted")

          {:error, _reason} ->
            send_resp(conn, :unprocessable_entity, "Error deleting author")
        end

      {:error, _reason} ->
        send_resp(conn, :not_found, "Author not found")
    end
  end
end
