defmodule MyAshBlogWeb.UserJSON do
  alias MyAshBlog.Blog.User

  def render("index.json", %{users: users}) do
    %{data: Enum.map(users, &user_to_json/1)}
  end

  def render("show.json", %{user: user}) do
    %{data: user_to_json(user)}
  end

  defp user_to_json(%User{id: id, username: username, email: email}) do
    %{
      id: id,
      username: username,
      email: email
    }
  end
end
