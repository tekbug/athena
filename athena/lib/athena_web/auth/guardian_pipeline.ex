defmodule AthenaWeb.Auth.GuardianPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :athena,
    error_handler: AthenaWeb.Auth.ErrorHandler,
    module: Athena.Accounts.Guardian

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
  plug(:verify_token_type)

  def verify_token_type(conn, _opts) do
    case Guardian.Plug.current_token(conn) do
      nil ->
        conn

      token ->
        claims = Guardian.Plug.current_claims(conn)
        verify_token_type_claims(conn, claims)
    end
  end

  defp verify_token_type_claims(conn, %{"typ" => "access"}) do
    conn
  end

  defp verify_token_type_claims(conn, _claims) do
    conn
    |> AthenaWeb.Auth.ErrorHandler.auth_error({:invalid_token_type, :invalid_token_type}, [])
    |> Plug.Conn.halt()
  end
end
