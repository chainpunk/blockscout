defmodule BlockScoutWeb.Tokens.InventoryController do
  use BlockScoutWeb, :controller

  alias Explorer.Chain

  import BlockScoutWeb.Chain, only: [split_list_by_page: 1, paging_options: 1, next_page_params: 3]

  def index(conn, %{"token_id" => address_hash_string} = params) do
    with {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string),
         {:ok, token} <- Chain.token_from_address_hash(address_hash) do

        unique_tokens =
          Chain.address_to_unique_tokens(
            token.contract_address_hash,
            paging_options(params)
          )

        {unique_tokens_paginated, next_page} = split_list_by_page(unique_tokens)

      render(
        conn,
        "index.html",
        token: token,
        unique_tokens: unique_tokens_paginated,
        total_token_transfers: Chain.count_token_transfers_from_token_hash(address_hash),
        total_token_holders: Chain.count_token_holders_from_token_hash(address_hash),
        next_page_params: next_page_params(next_page, unique_tokens_paginated, params)
      )
    else
      :error ->
        not_found(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
