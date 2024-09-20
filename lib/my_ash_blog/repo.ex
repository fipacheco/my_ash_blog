defmodule MyAshBlog.Repo do
  use AshPostgres.Repo,
    otp_app: :my_ash_blog


  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end

  
end
