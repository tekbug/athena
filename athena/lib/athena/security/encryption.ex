defmodule Athena.Security.Encryption do
  @aad "AthenaSecureData"

  def encrypt(data) when is_binary(data) or is_map(data) do
    try do
      key = get_encryption_key()
      iv = :crypto.strong_rand_bytes(12)

      serialized_data =
        if is_map(data) do
          Jason.encode!(data)
        else
          data
        end

      {cipher_text, tag} =
        :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, serialized_data, @aad, true)

      encrypted = iv <> tag <> cipher_text
      {:ok, Base.encode64(encrypted)}
    rescue
      e -> {:error, e}
    end
  end

  def decrypt(encrypted_data) when is_binary(encrypted_data) do
    try do
      key = get_encryption_key()
      decoded = Base.decode64!(encrypted_data)
      <<iv::binary-12, tag::binary-16, cipher_text::binary>> = decoded

      case(
        :crypto.crypto_one_time_aead(
          :aes_256_gcm,
          key,
          iv,
          cipher_text,
          @aad,
          tag,
          false
        )
      ) do
        decrypted when is_binary(decrypted) ->
          case Jason.decode(decrypted) do
            {:ok, decoded} -> {:ok, decoded}
            {:error, _} -> {:ok, decrypted}
          end

        :error ->
          {:error, :decryption_failed}
      end
    rescue
      e -> {:error, e}
    end
  end

  defp get_encryption_key do
    Application.get_env(:athena, :encryption_key) || raise "Encryption key is not configured!"
  end
end
