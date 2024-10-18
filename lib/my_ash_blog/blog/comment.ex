defmodule MyAshBlog.Blog.Comment do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "comments"
    repo MyAshBlog.Repo
  end

  resource do
    description "Recurso para comentários de usuários em posts."
  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, MyAshBlog.Blog.User do
      source_attribute :user_id
      destination_attribute :id
      description "Usuário que fez o comentário."
    end

    belongs_to :post, MyAshBlog.Blog.Post do
      source_attribute :post_id
      destination_attribute :id
      description "Post ao qual o comentário pertence."
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:content, :post_id]
      change set_attribute(:user_id, expr(^actor(:id)))
      description "Cria um comentário em um post, qualquer usuário pode comentar."
    end

    update :update do
      accept [:content]
      description "Permite que o autor do comentário o edite."
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
      forbid_unless always()
    end

    policy action_type([:update, :destroy]) do
      description "Usuário pode editar e excluir seus próprios comentários."
      authorize_if expr(user_id == ^actor(:id))
      forbid_unless always()
    end

    policy action_type(:destroy) do
      description "Admins podem excluir qualquer comentário."
      authorize_if expr(user.role == :admin)
      forbid_unless expr(user.role == :admin)
    end
  end

  json_api do
    type "comments"
  end
end
