defmodule MyAshBlog.Blog.Author do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "authors"
    repo MyAshBlog.Repo
  end

  resource do
    description("Resource com os autores cadastrados no blog")
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
      description "Nome do autor do texto. Campo Obrigatório"
    end

    attribute :email, :string do
      allow_nil? false
      public? true
      description "Email do autor do texto"
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :email]
      description "Cria um novo autor com nome e email"
    end

    update :update do
      accept [:name, :email]
      description "Atualiza o nome e email do autor"
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      description "Leitura de um autor com base no ID fornecido"
    end
  end

  json_api do
    type "authors"
  end
end
