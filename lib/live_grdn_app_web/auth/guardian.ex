defmodule LiveGrdnAppWeb.Auth.Guardian do
  use Guardian, otp_app: :live_grdn_app


  def build_claims(claims, resource, _opts) do
    role = Map.get(resource, :role, :user)
    permissions = Map.get(@roles, role, [])

    claims =
      claims
      |> add_claim(:role, Atom.to_string(role))
      |> add_claim(:permissions, permissions)

    {:ok, claims}
  end

  defp add_claim(claims, key, value) do
    Map.put(claims, Atom.to_string(key), value)
  end
  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_,_) do
    {:error,:no_id_provided}
  end

  def authenticate(email,password) do
    case UnliveApp.Accounts.get_user_by_email(email) do
      nil -> {:error ,:unauthorized}
      account ->
        case validate_password(password,account.hash_password) do
          true -> create_token(account)
          false -> {:error,:unauthorized}
        end
    end
  end

  def resource_from_claims(%{"sub" => id}) do
    case UnliveApp.Accounts.get_account!(id) do
      nil -> {:error,:not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_id_provided}
  end

  defp validate_password(password,hash_password)do
    Bcrypt.verify_pass(password,hash_password)
  end

  def create_token(account) do
    {:ok, token, _claims} = encode_and_sign(account)
    {:ok,account,token}
  end
end
