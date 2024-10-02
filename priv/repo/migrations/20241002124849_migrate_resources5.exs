defmodule MyAshBlog.Repo.Migrations.MigrateResources5 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:comments) do
      remove :author
    end
  end

  def down do
    alter table(:comments) do
      add :author, :text, null: false
    end
  end
end
