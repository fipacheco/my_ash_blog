defmodule MyAshBlogWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["MyAshBlog.Blog"])],
    open_api: "/open_api",
    open_api_title: "Teste da minha API",
    open_api_version: "alpha",
    open_api_description: "Documentação da API de Blog"
end
