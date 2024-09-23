defmodule MyAshBlogWeb.AuthorJSON do
  alias MyAshBlog.Blog.Author

  # Renderiza a lista de autores
  def render("index.json", %{authors: authors}) do
    %{data: Enum.map(authors, &author_to_json/1)}
  end

  # Renderiza um autor individual
  def render("show.json", %{author: author}) do
    %{data: author_to_json(author)}
  end

  # Função auxiliar para converter autor em JSON
  defp author_to_json(%Author{id: id, name: name, email: email}) do
    %{
      id: id,
      name: name,
      email: email
    }
  end
end
