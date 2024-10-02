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

    attribute :author_id, :uuid do
      description "ID do autor deste post"
    end

    timestamps()
  end

  relationships do
    belongs_to :author, MyAshBlog.Blog.Author do
      source_attribute :author_id
      description "Relacao um post pertence a um author"
    end

    has_many :comments, MyAshBlog.Blog.Comment do
      destination_attribute :post_id
      description "Relacao um post tem vários comentários"
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :content, :author_id]
      description "Cria um novo post com título, conteúdo e ID do autor"
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
