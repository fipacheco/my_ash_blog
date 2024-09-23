defmodule MyAshBlogWeb.UserController do
  use MyAshBlogWeb, :controller

  alias MyAshBlog.Blog

  # GET /api/users
  def index(conn, _params) do
    users = Blog.User |> Ash.Query.for_read(:read) |> Ash.read!()

    conn
    |> put_view(MyAshBlogWeb.UserJSON)
    |> render(:index, users: users)
  end

  # GET /api/users/:id
  def show(conn, %{"id" => id}) do
    case Blog.User |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, user} ->
        conn
        |> put_view(MyAshBlogWeb.UserJSON)
        |> render(:show, user: user)

      _ ->
        send_resp(conn, :not_found, "User not found")
    end
  end

  # POST /api/users
  def create(conn, %{"user" => user_params}) do
    changeset = Blog.User |> Ash.Changeset.for_create(:create, user_params)

    case Ash.create(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_view(MyAshBlogWeb.UserJSON)
        |> render(:show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # PUT /api/users/:id
  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Blog.User |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one!()

    changeset = user |> Ash.Changeset.for_update(:update, user_params)

    case Ash.update(changeset) do
      {:ok, user} ->
        conn
        |> put_view(MyAshBlogWeb.UserJSON)
        |> render(:show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(MyAshBlogWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # DELETE /api/users/:id
  def delete(conn, %{"id" => id}) do
    case Blog.User |> Ash.Query.for_read(:by_id, %{id: id}) |> Ash.read_one() do
      {:ok, nil} ->
        send_resp(conn, :not_found, "User not found")

      {:ok, user} ->
        case Ash.destroy(user) do
          :ok ->
            send_resp(conn, :ok, "User deleted")

          {:ok, _user} ->
            send_resp(conn, :ok, "User deleted")

          {:error, _reason} ->
            send_resp(conn, :unprocessable_entity, "Error deleting user")
        end

      {:error, _reason} ->
        send_resp(conn, :not_found, "User not found")
    end
  end
end
