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
      description "Nome do autor do texto. Campo Obrigatório"
    end

    attribute :email, :string do
      allow_nil? false
      description "Email do autor do texto"
    end

    timestamps()
  end

  relationships do
    has_many :posts, MyAshBlog.Blog.Post do
      destination_attribute :author_id
      description "Um autor tem vários posts"
    end
  end

  actions do
    create :create do
      accept [:name, :email]
    end

    defaults [:read, :destroy, :update]
  end

  json_api do
    type "authors"
  end
end
