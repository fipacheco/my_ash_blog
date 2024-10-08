defmodule MyAshBlog.Blog.AuthToken do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    domain: MyAshBlog.Blog

  postgres do
    table "auth_tokens"
    repo MyAshBlog.Repo
  end
end
