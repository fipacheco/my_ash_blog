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

    attribute :user_id, :uuid do
      description "ID do usuário que fez o comentário"
    end

    attribute :post_id, :uuid do
      description "ID do post ao qual este comentário pertence"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, MyAshBlog.Blog.User do
      source_attribute :user_id
      destination_attribute :id
      description "Relacao um comentário pertence a um usuário"
    end

    belongs_to :post, MyAshBlog.Blog.Post do
      source_attribute :post_id
      destination_attribute :id
      description "Relacao um comentario pertence a um post"
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:content, :user_id, :post_id]
      description "Cria um novo comentário com o conteúdo, autor, usuário e post relacionados"
    end

    update :update do
      accept [:content, :user_id]
      description "Atualiza o conteúdo e autor de um comentário"
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
