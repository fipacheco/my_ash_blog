defmodule MyAshBlog.Blog.Comment do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "comments"
    repo MyAshBlog.Repo
  end

  resource do
    description("Resource com os comentários cadastrados no blog")
  end

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
      public? true
      description "Conteúdo do comentário. Campo Obrigatório"
    end

    attribute :author_name, :string do
      allow_nil? false
      public? true
      description "Nome do autor do comentário"
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:content, :author_name]
      description "Cria um novo comentário com o conteúdo e o nome do autor"
    end

    update :update do
      accept [:content, :author_name]
      description "Função para atualização do conteúdo e nome do autor do comentário"
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      description "Leitura de um comentário com base no ID fornecido"
    end
  end

  json_api do
    type "comments"
  end
end
