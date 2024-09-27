defmodule MyAshBlog.Blog.Post do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "posts"
    repo MyAshBlog.Repo
  end

  resource do
    description "Resource dos posts do blog"
  end

  attributes do
    uuid_primary_key :id do
      description "Identificador único do post"
    end

    attribute :title, :string do
      allow_nil? false
      public? true
      description "Título do post. Campo obrigatório"
    end

    attribute :content, :string do
      allow_nil? false
      public? true
      description "Conteúdo do post. Campo obrigatório"
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :content]
      description "Cria um novo post com título e conteúdo"
    end

    update :update do
      accept [:title, :content]
      description "Atualiza o título e o conteúdo de um post existente"
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      description "Leitura de um post com base no ID fornecido"
    end
  end

  json_api do
    type "posts"
  end
end
