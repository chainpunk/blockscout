defmodule BlockScoutWeb.AddressInternalTransactionController do
  @moduledoc """
    Manages the displaying of information about internal transactions as they relate to addresses
  """

  use BlockScoutWeb, :controller

  import BlockScoutWeb.Chain,
    only: [current_filter: 1, paging_options: 1, next_page_params: 3, split_list_by_page: 1]

  alias Explorer.{Chain}

  def index(conn, %{"address_id" => address_hash_string} = params) do
    with {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string),
         {:ok, address} <- Chain.hash_to_address(address_hash) do
      full_options =
        [
          necessity_by_association: %{
            [created_contract_address: :names] => :optional,
            [from_address: :names] => :optional,
            [to_address: :names] => :optional
          }
        ]
        |> Keyword.merge(paging_options(params))
        |> Keyword.merge(current_filter(params))

      internal_transactions_plus_one =
        Chain.address_to_internal_transactions(address, full_options)

      {internal_transactions, next_page} = split_list_by_page(internal_transactions_plus_one)

      assigns = %{
        address: address,
        next_page_params: next_page_params(next_page, internal_transactions, params),
        filter: params["filter"],
        internal_transactions: internal_transactions
      }

      render(conn, "index.html", AddressPage.build_params(assigns))
    end
  end
end
