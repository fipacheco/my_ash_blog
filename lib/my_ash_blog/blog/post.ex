defmodule MyAshBlog.Blog.Post do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "posts"
    repo MyAshBlog.Repo
  end

  resource do
    description "Recurso para posts criados por autores."
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :content, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, MyAshBlog.Blog.User do
      source_attribute :user_id
      destination_attribute :id
      description "Usuário autor do post."
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :content]
      change set_attribute(:user_id, expr(^actor(:id)))
      description "Cria um novo post, disponível apenas para autores."
    end

    update :update do
      accept [:title, :content]
      description "Permite que o autor edite seu post."
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      description "Busca um post pelo ID."
    end
  end

    policies do
      policy action_type(:create) do
        description "Apenas autores podem criar posts."
        authorize_if expr(is_author == true and user_id == ^actor(:id))
        forbid_unless expr(is_author == true and user_id == ^actor(:id))
      end

      policy action_type(:update) do
        description "Apenas autores podem atualizar seus próprios posts."
        authorize_if expr(is_author == true and user_id == ^actor(:id))
        forbid_unless always()
      end

      policy action_type(:read) do
        authorize_if always()
      end

      policy action_type(:destroy) do
        description "Apenas o autor pode excluir seus próprios posts, e admins podem excluir qualquer post."
        authorize_if expr(user_id == ^actor(:id))
        authorize_if expr(role == :admin)
        forbid_unless expr(user_id == ^actor(:id) or role == :admin)
      end
    end

  json_api do
    type "posts"
  end
end
