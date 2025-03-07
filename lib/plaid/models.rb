require 'hashie'

module Plaid
  module Models
    # Internal: Base model for all other models.
    class BaseModel < Hashie::Dash
      include Hashie::Extensions::Dash::IndifferentAccess
      include Hashie::Extensions::Dash::Coercion

      @ignored_properties = []

      def self.property_ignored?(property)
        if defined? @ignored_properties
          @ignored_properties.include?(property)
        else
          false
        end
      end

      # Internal: Be strict or forgiving depending on Plaid.relaxed_models
      # value.
      def assert_property_exists!(property)
        super unless Plaid.relaxed_models? ||
                     self.class.property_ignored?(property)
      end
    end

    # Internal: Base API response.
    class BaseResponse < BaseModel
      ##
      # :attr_reader:
      # Public: The String request ID assigned by the API.
      property :request_id
    end

    # Internal: Base error.
    class BaseError < BaseModel
      ##
      # :attr_reader:
      # Public: The String broad categorization of the error. One of:
      # 'INVALID_REQUEST', 'INVALID_INPUT', 'RATE_LIMIT_EXCEEDED', 'API_ERROR',
      # or 'ITEM_ERROR'.
      property :error_type

      ##
      # :attr_reader:
      # Public: The particular String error code. Each error_type has a
      # specific set of error_codes.
      property :error_code

      ##
      # :attr_reader:
      # Public: A developer-friendly representation of the error message.
      property :error_message

      ##
      # :attr_reader:
      # Public: A user-friendly representation of the error message. nil if the
      # error is not related to user action.
      property :display_message
    end

    # Public: A representation of a cause.
    class Cause < BaseError
      ##
      # :attr_reader:
      # Public: The item ID.
      property :item_id
    end

    # Public: A representation of an error.
    class Error < BaseError
      ##
      # :attr_reader:
      # Public: A list of reasons explaining why the error happened.
      property :causes, coerce: Array[Cause]
    end

    # Public: A representation of a warning.
    class Warning < BaseModel
      ##
      # :attr_reader:
      # Public: The type of warning.
      property :warning_type

      ##
      # :attr_reader:
      # Public: The warning code.
      property :warning_code

      ##
      # :attr_reader:
      # Public: The underlying cause.
      property :cause, coerce: Cause
    end

    # Public: A representation of an item.
    class Item < BaseModel
      ##
      # :attr_reader:
      # Public: The Array with String products available for this item
      # (e.g. ["balance", "auth"]).
      property :available_products

      ##
      # :attr_reader:
      # Public: The Array with String products billed for this item
      # (e.g. ["identity", "transactions"]).
      property :billed_products

      ##
      # :attr_reader:
      # Public: The String error related to
      property :error, coerce: Error

      ##
      # :attr_reader:
      # Public: The String institution ID for this item.
      property :institution_id

      ##
      # :attr_reader:
      # Public: The String item ID.
      property :item_id

      ##
      # :attr_reader:
      # Public: The String update type.
      property :update_type

      ##
      # :attr_reader:
      # Public: The String webhook URL.
      property :webhook

      ##
      # :attr_reader:
      # Public: The String consent expiration timestamp (or nil)
      # (e.g. "2019-04-22T00:00:00Z").
      property :consent_expiration_time

      ##
      # :attr_reader:
      # Public: The String update type.
      property :update_type
    end

    # Public: A representation of Item webhook status
    class ItemStatusLastWebhook < BaseModel
      ##
      # :attr_reader:
      # Public: The String last code sent (or nil).
      # (e.g. "HISTORICAL_UPDATE").
      property :code_sent

      ##
      # :attr_reader:
      # Public: the String sent at date (or nil).
      # (e.g. "2019-04-22T00:00:00Z").
      property :sent_at
    end

    # Public: A representation of Item transaction update status
    class ItemStatusTransactions < BaseModel
      ##
      # :attr_reader:
      # Public: the String last failed update date (or nil).
      # (e.g. "2019-04-22T00:00:00Z").
      property :last_failed_update

      ##
      # :attr_reader:
      # Public: the String last successful update date (or nil).
      # (e.g. "2019-04-22T00:00:00Z").
      property :last_successful_update
    end

    # Public: A representation of Item investments update status
    class ItemStatusInvestments < BaseModel
      ##
      # :attr_reader:
      # Public: the String last failed update date (or nil).
      # (e.g. "2019-04-22T00:00:00Z").
      property :last_failed_update

      ##
      # :attr_reader:
      # Public: the String last successful update date (or nil).
      # (e.g. "2019-04-22T00:00:00Z").
      property :last_successful_update
    end

    # Public: A representation of Item status
    class ItemStatus < BaseModel
      ##
      # :attr_reader:
      # Public: The ItemStatusLastWebhook for this ItemStatus.
      property :last_webhook, coerce: ItemStatusLastWebhook

      ##
      # :attr_reader:
      # Public: The ItemStatusTransactions for this ItemStatus.
      property :transactions, coerce: ItemStatusTransactions

      ##
      # :attr_reader:
      # Public: The ItemStatusInvestments for this ItemStatus.
      property :investments, coerce: ItemStatusInvestments
    end

    # Public: A representation of account balances.
    class Balances < BaseModel
      ##
      # :attr_reader:
      # Public: The Numeric available balance (or nil).
      property :available

      ##
      # :attr_reader:
      # Public: The Numeric current balance (or nil).
      property :current

      ##
      # :attr_reader:
      # Public: The Numeric limit (or nil).
      property :limit

      ##
      # :attr_reader:
      # Public: The String ISO currency code for the amount
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The String unofficial currency code for the amount
      property :unofficial_currency_code
    end

    # Public: A representation of an account.
    class Account < BaseModel
      ##
      # :attr_reader:
      # Public: The String account ID, e.g.
      # "QKKzevvp33HxPWpoqn6rI13BxW4awNSjnw4xv".
      property :account_id

      ##
      # :attr_reader:
      # Public: Balances for this account.
      property :balances, coerce: Balances

      ##
      # :attr_reader:
      # Public: The String mask, e.g. "0000".
      property :mask

      ##
      # :attr_reader:
      # Public: The String account name, e.g. "Plaid Checking".
      property :name

      ##
      # :attr_reader:
      # Public: The String official account name, e.g. "Plaid Gold Checking".
      property :official_name

      ##
      # :attr_reader:
      # Public: The String type, e.g. "depository".
      property :type

      ##
      # :attr_reader:
      # Public: The String subtype, e.g. "checking".
      property :subtype

      ##
      # :attr_reader:
      # Public: The String verification status,
      # e.g "manually_verified" (optional).
      property :verification_status
    end

    # Public: A representation of an ACH account number.
    class NumberACH < BaseModel
      ##
      # :attr_reader:
      # Public: The String account number. E.g. "1111222233330000".
      property :account

      ##
      # :attr_reader:
      # Public: The String account ID. E.g.
      # "vzeNDwK7KQIm4yEog683uElbp9GRLEFXGK98D".
      property :account_id

      ##
      # :attr_reader:
      # Public: The String routing number. E.g. "011401533".
      property :routing

      ##
      # :attr_reader:
      # Public: The String wire routing number. E.g. "021000021".
      property :wire_routing
    end

    # Public: A representation of an EFT (Canadian) account number.
    class NumberEFT < BaseModel
      ##
      # :attr_reader:
      # Public: The String account number. E.g. "1111222233330000".
      property :account

      ##
      # :attr_reader:
      # Public: The String account ID. E.g.
      # "vzeNDwK7KQIm4yEog683uElbp9GRLEFXGK98D".
      property :account_id

      ##
      # :attr_reader:
      # Public: The String branch number. E.g. "021".
      property :branch

      ##
      # :attr_reader:
      # Public: The String institution number. E.g. "01140".
      property :institution
    end

    # Public: A representation of an International account number.
    class NumberInternational < BaseModel
      ##
      # :attr_reader:
      # Public: The String account ID. E.g.
      # "vzeNDwK7KQIm4yEog683uElbp9GRLEFXGK98D".
      property :account_id

      ##
      # :attr_reader:
      # Public: The String International Bank Account Number (IBAN). E.g.
      # "GB33BUKB20201555555555".
      property :iban

      ##
      # :attr_reader:
      # Public: The String Bank Identifier Code (BIC). E.g. "BUKBGB22".
      property :bic
    end

    # Public: A representation of a BACS (British) account number.
    class NumberBACS < BaseModel
      ##
      # :attr_reader:
      # Public: The String account ID. E.g.
      # "vzeNDwK7KQIm4yEog683uElbp9GRLEFXGK98D".
      property :account_id

      ##
      # :attr_reader:
      # Public: The String account number. E.g. "66374958".
      property :account

      ##
      # :attr_reader:
      # Public: The String sort code. E.g. "089999".
      property :sort_code
    end

    # Public: A representation of a Auth Numbers response
    class Numbers < BaseModel
      ##
      # :attr_reader:
      # Public: The Array of NumberACH.
      property :ach, coerce: Array[NumberACH]

      ##
      # :attr_reader:
      # Public: The Array of NumberEFT.
      property :eft, coerce: Array[NumberEFT]

      ##
      # :attr_reader:
      # Public: The Array of NumberInternational.
      property :international, coerce: Array[NumberInternational]

      ##
      # :attr_reader:
      # Public: The Array of NumberBACS.
      property :bacs, coerce: Array[NumberBACS]
    end

    # Public: A representation of a transaction category.
    class Category < BaseModel
      ##
      # :attr_reader:
      # Public: The String category ID. E.g. "10000000".
      property :category_id

      ##
      # :attr_reader:
      # Public: The Array of Strings category hierarchy.
      # E.g. ["Recreation", "Arts & Entertainment", "Circuses and Carnivals"].
      property :hierarchy

      ##
      # :attr_reader:
      # Public: The String category group. E.g. "place".
      property :group
    end

    # Public: A representation of a single Credit Details APR.
    class CreditDetailsAPR < BaseModel
      ##
      # :attr_reader:
      # Public: The Numeric APR (e.g. 0.125).
      property :apr

      ##
      # :attr_reader:
      # Public: The Numeric balance subject to APR (e.g. 1200).
      property :balance_subject_to_apr

      ##
      # :attr_reader:
      # Public: The Numeric interest charge amount (e.g. 150).
      property :interest_charge_amount
    end

    # Public: A representation of Credit Details APRs data.
    class CreditDetailsAPRs < BaseModel
      ##
      # :attr_reader:
      # Public: Balance transfers APR
      property :balance_transfers, coerce: CreditDetailsAPR

      ##
      # :attr_reader:
      # Public: Cash advances APR
      property :cash_advances, coerce: CreditDetailsAPR

      ##
      # :attr_reader:
      # Public: Purchases APR
      property :purchases, coerce: CreditDetailsAPR
    end

    # Public: A representation of Credit Details data.
    class CreditDetails < BaseModel
      ##
      # :attr_reader:
      # Public: The String account ID. E.g.
      # "vzeNDwK7KQIm4yEog683uElbp9GRLEFXGK98D".
      property :account_id

      ##
      # :attr_reader:
      # Public: The APRs.
      property :aprs, coerce: CreditDetailsAPRs

      ##
      # :attr_reader:
      # Public: The Numeric last payment amount (e.g. 875).
      property :last_payment_amount

      ##
      # :attr_reader:
      # Public: The String last payment date. E.g. "2016-09-13T00:00:00Z".
      property :last_payment_date

      ##
      # :attr_reader:
      # Public: The Numeric last statement balance (e.g. 3450).
      property :last_statement_balance

      ##
      # :attr_reader:
      # Public: The String last statement date. E.g. "2016-10-01T00:00:00Z".
      property :last_statement_date

      ##
      # :attr_reader:
      # Public: The Numeric minimum payment amount (e.g. 800).
      property :minimum_payment_amount

      ##
      # :attr_reader:
      # Public: The String next bill due date. E.g. "2016-10-15T00:00:00Z".
      property :next_bill_due_date
    end

    # Public: A representation of Identity address details.
    class IdentityAddressData < BaseModel
      ##
      # :attr_reader:
      # Public: The String street name.
      property :street

      ##
      # :attr_reader:
      # Public: The String name.
      property :city

      ##
      # :attr_reader:
      # Public: The String region or state name.
      property :region

      ##
      # :attr_reader:
      # Public: The String postal code.
      property :postal_code

      ##
      # :attr_reader:
      # Public: The String country code.
      property :country
    end

    # Public: A representation of Identity address data.
    class IdentityAddress < BaseModel
      ##
      # :attr_reader:
      # Public: The Boolean primary flag (true if it's the primary address).
      property :primary

      ##
      # :attr_reader:
      # Public: The address data.
      property :data, coerce: IdentityAddressData
    end

    # Public: A representation of Identity email data.
    class IdentityEmail < BaseModel
      ##
      # :attr_reader:
      # Public: The String data, i.e. the address itself. E.g.
      # "accountholder0@example.com".
      property :data

      ##
      # :attr_reader:
      # Public: The Boolean primary flag.
      property :primary

      ##
      # :attr_reader:
      # Public: The String type. E.g. "primary", or "secondary", or "other".
      property :type
    end

    # Public: A representation of Identity phone number data.
    class IdentityPhoneNumber < BaseModel
      ##
      # :attr_reader:
      # Public: The String data, i.e. the number itself. E.g.
      # "4673956022".
      property :data

      ##
      # :attr_reader:
      # Public: The Boolean primary flag.
      property :primary

      ##
      # :attr_reader:
      # Public: The String type. E.g. "home", or "work", or "mobile1".
      property :type
    end

    # Public: A representation of Identity data.
    class Identity < BaseModel
      ##
      # :attr_reader:
      # Public: Addresses: Array of IdentityAddress.
      property :addresses, coerce: Array[IdentityAddress]

      ##
      # :attr_reader:
      # Public: Emails: Array of IdentityEmail.
      property :emails, coerce: Array[IdentityEmail]

      ##
      # :attr_reader:
      # Public: The Array of String names. E.g. ["John Doe", "Ronald McDonald"].
      property :names

      ##
      # :attr_reader:
      # Public: Phone numbers: Array of IdentityPhoneNumber.
      property :phone_numbers, coerce: Array[IdentityPhoneNumber]
    end

    # Public: A representation of Income Stream data.
    class IncomeStream < BaseModel
      ##
      # :attr_reader:
      # Public: The Numeric monthly income associated with the income stream.
      property :monthly_income

      ##
      # :attr_reader:
      # Public: The Numeric representation of our confidence in the income data
      # associated with this particular income stream, with 0 being the lowest
      # confidence and 1 being the highest.
      property :confidence

      ##
      # :attr_reader:
      # Public: The Numeric extent of data found for this income stream.
      property :days

      ##
      # :attr_reader:
      # Public: The String name of the entity associated with this income
      # stream.
      property :name
    end

    # Public: A representation of an account with owners
    class AccountWithOwners < Account
      ##
      # :attr_reader:
      # Public: The Array of owners.
      property :owners, coerce: Array[Identity]
    end

    # Public: A representation of Income data.
    class Income < BaseModel
      ##
      # :attr_reader:
      # Public: An Array of IncomeStream with detailed information.
      property :income_streams, coerce: Array[IncomeStream]

      ##
      # :attr_reader:
      # Public: The Numeric last year income, i.e. the sum of the Item's
      # income over the past 365 days. If Plaid has less than 365 days of data
      # this will be less than a full year's income.
      property :last_year_income

      ##
      # :attr_reader:
      # Public: The Numeric last_year_income interpolated to value before
      # taxes. This is the minimum pre-tax salary that assumes a filing status
      # of single with zero dependents.
      property :last_year_income_before_tax

      ##
      # :attr_reader:
      # Public: The Numeric income extrapolated over a year based on current,
      # active income streams. Income streams become inactive if they have not
      # recurred for more than two cycles. For example, if a weekly paycheck
      # hasn't been seen for the past two weeks, it is no longer active.
      property :projected_yearly_income

      ##
      # :attr_reader:
      # Public: The Numeric projected_yearly_income interpolated to value
      # before taxes. This is the minimum pre-tax salary that assumes a filing
      # status of single with zero dependents.
      property :projected_yearly_income_before_tax

      ##
      # :attr_reader:
      # Public: The Numeric max number of income streams present at the same
      # time over the past 365 days.
      property :max_number_of_overlapping_income_streams

      ##
      # :attr_reader:
      # Public: The Numeric total number of distinct income streams received
      # over the past 365 days.
      property :number_of_income_streams
    end

    # Public: A representation of an institution login credential.
    class InstitutionCredential < BaseModel
      @ignored_properties = ['flexible_input_spec']

      ##
      # :attr_reader:
      # Public: The String label. E.g. "User ID".
      property :label

      ##
      # :attr_reader:
      # Public: The String name. E.g. "username".
      property :name

      ##
      # :attr_reader:
      # Public: The String type. E.g. "text", or "password".
      property :type
    end

    # Public: A representation of Institution status breakdown.
    class InstitutionStatusBreakdown < BaseModel
      ##
      # :attr_reader:
      # Public: The Numeric success percentage.
      # (e.g. 0.970)
      property :success

      ##
      # :attr_reader:
      # Public: The Numeric Plaid error percentage.
      # (e.g. 0.010)
      property :error_plaid

      ##
      # :attr_reader:
      # Public: The Numeric Institution error percentage.
      # (e.g. 0.020)
      property :error_institution
    end

    # Public: A representation of Institution item logins status.
    class InstitutionStatusItemLogins < BaseModel
      ##
      # :attr_reader:
      # Public: The String last status change date.
      # (e.g. "2019-04-22T20:52:00Z")
      property :last_status_change

      ##
      # :attr_reader:
      # Public: The String status.
      # (e.g. one of "HEALTHY"|"DEGRADED"|"DOWN")
      property :status

      ##
      # :attr_reader:
      # Public: The breakdown for this Institution status.
      property :breakdown, coerce: InstitutionStatusBreakdown
    end

    # Public: A representation of Institution status.
    class InstitutionStatus < BaseModel
      ##
      # :attr_reader:
      # Public: The Item logins status for this InstitutionStatus.
      property :item_logins, coerce: InstitutionStatusItemLogins
    end

    # Public: A representation of standing order metadata for an institution.
    class StandingOrderMetadata < BaseModel
      ##
      # :attr_reader:
      # Public: The Boolean flag indicating if the institution supports
      # end date for standing orders.
      property :supports_standing_order_end_date

      ##
      # :attr_reader:
      # Public: The Boolean flag indicating if the institution supports
      # negative execution days for standing orders.
      property :supports_standing_order_negative_execution_days

      ##
      # :attr_reader:
      # Public: The Array of valid standing order intervals for
      # this institution.
      # E.g. ["WEEKLY", "MONTHLY"].
      property :valid_standing_order_intervals
    end

    # Public: A representation of an institution's payment initiation metadata.
    class InstitutionPaymentInitiationMetadata < BaseModel
      ##
      # :attr_reader:
      # Public: The map of maximum payment amount per currency for this
      # institution.
      # E.g. {"GBP"=>"1000000"}.
      property :maximum_payment_amount

      ##
      # :attr_reader:
      # Public: The standing order metadata for this institution.
      property :standing_order_metadata, coerce: StandingOrderMetadata

      ##
      # :attr_reader:
      # Public: The Boolean flag indicating if the institution supports
      # international payments.
      property :supports_international_payments

      ##
      # :attr_reader:
      # Public: The Boolean flag indicating if the institution supports
      # refund details.
      property :supports_refund_details
    end

    # Public: A representation of Institution.
    class Institution < BaseModel
      @ignored_properties = ['input_spec']

      ##
      # :attr_reader:
      # Public: The Array of InstitutionCredential, presenting information on
      # login credentials used for the institution.
      property :credentials, coerce: Array[InstitutionCredential]

      ##
      # :attr_reader:
      # Public: The Boolean flag indicating if the institution uses MFA.
      property :has_mfa

      ##
      # :attr_reader:
      # Public: The String reflecting the MFA code type ("numeric" /
      # "alphanumeric")
      property :mfa_code_type

      ##
      # :attr_reader:
      # Public: The String institution ID (e.g. "ins_109512").
      property :institution_id

      ##
      # :attr_reader:
      # Public: The String institution name (e.g. "Houndstooth Bank").
      property :name

      ##
      # :attr_reader:
      # Public: The Array of String MFA types.
      # E.g. ["code", "list", "questions", "selections"].
      property :mfa

      ##
      # :attr_reader:
      # Public: The Array of String product names supported by this institution.
      # E.g. ["auth", "balance", "identity", "transactions"].
      property :products

      ##
      # :attr_reader:
      # Public: The Array of String country codes supported by this institution.
      # E.g. ["US", "GB"].
      property :country_codes

      ##
      # :attr_reader:
      # Public: The String primary color for this institution (e.g. "#095aa6").
      property :primary_color

      ##
      # :attr_reader:
      # Public: The String base 64 encoded logo for this institution.
      property :logo

      ##
      # :attr_reader:
      # Public: The String base 64 encoded url for this institution
      # E.g. "https://www.plaid.com").
      property :url

      ##
      # :attr_reader:
      # Public: The Status for this Institution (or nil).
      property :status, coerce: InstitutionStatus

      ##
      # :attr_reader:
      # Public: The Array of String country codes supported by this institution.
      property :country_codes

      ##
      # :attr_reader:
      # Public: The array of routing numbers associated with this institution.
      property :routing_numbers

      ##
      # :attr_reader:
      # Public: Indicates that the institution has an OAuth login flow.
      property :oauth

      ##
      # :attr_reader:
      # Public: Specifies metadata related to the payment_initiation product
      # (or nil).
      property :payment_initiation_metadata,
               coerce: InstitutionPaymentInitiationMetadata
    end

    module MFA
      # Public: A representation of an MFA device.
      class Device < BaseModel
        ##
        # :attr_reader:
        # Public: The String message related to sending code to the device.
        property :display_message
      end

      # Public: A representation of a single element in a device list.
      class DeviceListElement < BaseModel
        ##
        # :attr_reader:
        # Public: The String device ID.
        property :device_id

        ##
        # :attr_reader:
        # Public: The String device mask.
        property :mask

        ##
        # :attr_reader:
        # Public: The String device type.
        property :type
      end

      # Public: A representation of MFA selection.
      class Selection < BaseModel
        ##
        # :attr_reader:
        # Public: The String question.
        property :question

        ##
        # :attr_reader:
        # Public: The Array of String answers.
        property :answers
      end
    end

    # Public: A representation of Transaction location.
    class TransactionLocation < BaseModel
      ##
      # :attr_reader:
      # Public: The String address (or nil).
      property :address

      ##
      # :attr_reader:
      # Public: The String city name (or nil).
      property :city

      ##
      # :attr_reader:
      # Public: The Numeric latitude of the place (or nil).
      property :lat

      ##
      # :attr_reader:
      # Public: The Numeric longitude of the place (or nil).
      property :lon

      ##
      # :attr_reader:
      # Public: The String region or state name (or nil).
      property :region

      ##
      # :attr_reader:
      # Public: The String store number (or nil).
      property :store_number

      ##
      # :attr_reader:
      # Public: The String postal code (or nil).
      property :postal_code

      ##
      # :attr_reader:
      # Public: The country code (or nil).
      property :country
    end

    # Public: A representation of Transaction Payment meta information.
    class TransactionPaymentMeta < BaseModel
      ##
      # :attr_reader:
      property :by_order_of
      ##
      # :attr_reader:
      property :ppd_id
      ##
      # :attr_reader:
      property :payee
      ##
      # :attr_reader:
      property :payer
      ##
      # :attr_reader:
      property :payment_method
      ##
      # :attr_reader:
      property :payment_processor
      ##
      # :attr_reader:
      property :reason
      ##
      # :attr_reader:
      property :reference_number
    end

    # Public: A representation of Transaction.
    class Transaction < BaseModel
      ##
      # :attr_reader:
      # Public: The String transaction ID.
      property :transaction_id

      ##
      # :attr_reader:
      # Public: The String account ID.
      property :account_id

      ##
      # :attr_reader:
      # Public: The String account owner (or nil).
      property :account_owner

      ##
      # :attr_reader:
      # Public: The Numeric amount (or nil).
      property :amount

      ##
      # :attr_reader:
      # Public: The Array of String category (or nil).
      # E.g. ["Payment", "Credit Card"].
      property :category

      ##
      # :attr_reader:
      # Public: The String category_id (or nil).
      # E.g. "16001000".
      property :category_id

      ##
      # :attr_reader:
      # Public: The String transaction date. E.g. "2017-01-01".
      property :date

      ##
      # :attr_reader:
      # Public: The location where transaction occurred (TransactionLocation).
      property :location, coerce: TransactionLocation

      ##
      # :attr_reader:
      # Public: The String merchant name (or nil).
      # E.g. "Burger King".
      property :merchant_name

      ##
      # :attr_reader:
      # Public: The String transaction name (or nil).
      # E.g. "CREDIT CARD 3333 PAYMENT *//".
      property :name

      ##
      # :attr_reader:
      # Public: The String original description (or nil).
      property :original_description

      ##
      # :attr_reader:
      # Public: The payment meta information (TransactionPaymentMeta).
      property :payment_meta, coerce: TransactionPaymentMeta

      ##
      # :attr_reader:
      # Public: The Boolean pending flag (or nil).
      property :pending

      ##
      # :attr_reader:
      # Public: The String pending transaction ID (or nil).
      property :pending_transaction_id

      ##
      # :attr_reader:
      # Public: The String transaction type (or nil). E.g. "special", or
      # "place".
      property :transaction_type

      ##
      # :attr_reader:
      # Public: The String ISO currency code for the amount
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The String unofficial currency code for the amount
      property :unofficial_currency_code

      ##
      # :attr_reader:
      # Public: The String channel used to make a payment, e.g.
      # "online", "in store", or "other".
      property :payment_channel

      ##
      # :attr_reader:
      # Public: The String date that the transaction was authorized,
      # e.g. "2017-01-01".
      property :authorized_date

      ##
      # :attr_reader:
      # Public: The String transaction code, e.g. "direct debit".
      property :transaction_code
    end

    # Public: A representation of an InvestmentTransaction in an investment
    # account.
    class InvestmentTransaction < BaseModel
      ##
      # :attr_reader:
      # Public: The String investment transaction ID.
      property :investment_transaction_id

      ##
      # :attr_reader:
      # Public: The String account ID.
      property :account_id

      ##
      # :attr_reader:
      # Public: The String security ID.
      property :security_id

      ##
      # :attr_reader:
      # Public: The String transaction date. E.g. "2017-01-01".
      property :date

      ##
      # :attr_reader:
      # Public: The String transaction name (or nil).
      # E.g. "CREDIT CARD 3333 PAYMENT *//".
      property :name

      ##
      # :attr_reader:
      # Public: The Numeric quantity of the security involved (if applicable).
      property :quantity

      ##
      # :attr_reader:
      # Public: The Numeric amount (or nil).
      property :amount

      ##
      # :attr_reader:
      # Public: The Numeric price of the security that was used for the trade
      # (if applicable).
      property :price

      ##
      # :attr_reader:
      # Public: The Numeric fee amount.
      property :fees

      ##
      # :attr_reader:
      # Public: The String transaction type (or nil). E.g. "buy" or "sell".
      property :type

      ##
      # :attr_reader:
      # Public: The String transaction type (or nil). E.g. "buy" or "sell".
      property :subtype

      ##
      # :attr_reader:
      # Public: The ISO currency code of the transaction, either USD or CAD.
      # Always nil if unofficial_currency_code is non-nil.
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The unofficial currency code associated with the transaction.
      # Always nil if iso_currency_code is non-nil.
      property :unofficial_currency_code

      ##
      # :attr_reader:
      # Public: Present if the transaction class is cancel, and indicates the
      # ID of the transaction which was cancelled.
      property :cancel_transaction_id
    end

    # Public: A representation of a Holding in an investment account.
    class Holding < BaseModel
      ##
      # :attr_reader:
      # Public: The String account ID.
      property :account_id

      ##
      # :attr_reader:
      # Public: The String security ID.
      property :security_id

      ##
      # :attr_reader:
      # Public: The Numeric value of the holding (price * quantity) as reported
      # by the institution.
      property :institution_value

      ##
      # :attr_reader:
      # Public: The Numeric price of the holding as reported by the institution.
      property :institution_price

      ##
      # :attr_reader:
      # Public: The Numeric quantity.
      property :quantity

      ##
      # :attr_reader:
      # Public: The String date when the price reported by the institution was
      # current. E.g. "2017-01-01".
      property :institution_price_as_of

      ##
      # :attr_reader:
      # Public: The Numeric cost basis.
      property :cost_basis

      ##
      # :attr_reader:
      # Public: The ISO currency code of the holding, either USD or CAD.
      # Always nil if unofficial_currency_code is non-nil.
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The unofficial currency code associated with the holding.
      # Always nil if iso_currency_code is non-nil.
      property :unofficial_currency_code
    end

    # Public: A representation of a Security.
    class Security < BaseModel
      ##
      # :attr_reader:
      # Public: The String security ID.
      property :security_id

      ##
      # :attr_reader:
      # Public: The String CUSIP identitfier of this security.
      property :cusip

      ##
      # :attr_reader:
      # Public: The String SEDOL identifier of this security.
      property :sedol

      ##
      # :attr_reader:
      # Public: The String ISIN identifier of this security.
      property :isin

      ##
      # :attr_reader:
      # Public: The String ID of this security as reported by the institution.
      property :institution_security_id

      ##
      # :attr_reader:
      # Public: The String institution ID (if institution_security_id is set).
      property :institution_id

      ##
      # :attr_reader:
      # Public: The String security ID of the proxied security.
      property :proxy_security_id

      ##
      # :attr_reader:
      # Public: The String security name.
      property :name

      ##
      # :attr_reader:
      # Public: The String ticker symbol.
      property :ticker_symbol

      ##
      # :attr_reader:
      # Public: The Boolean flag indicating whether this security is
      # cash-equivalent.
      property :is_cash_equivalent

      ##
      # :attr_reader:
      # Public: The String Type.
      property :type

      ##
      # :attr_reader:
      # Public: The Numeric close price.
      property :close_price

      ##
      # :attr_reader:
      # Public: The String date when the close price was current.
      property :close_price_as_of

      ##
      # :attr_reader:
      # Public: The ISO currency code of the security, either USD or CAD.
      # Always nil if unofficial_currency_code is non-nil.
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The unofficial currency code associated with the security.
      # Always nil if iso_currency_code is non-nil.
      property :unofficial_currency_code
    end

    # Public: A representation of an asset report owner.
    class AssetReportOwner < BaseModel
      ##
      # :attr_reader:
      # Public: A list of names associated with the account by the financial
      # institution.
      property :names, coerce: Array[String]

      ##
      # :attr_reader:
      # Public: A list of phone numbers associated with the account by the
      # financial institution; see IdentityPhoneNumber number object for
      # fields.
      property :phone_numbers, coerce: Array[IdentityPhoneNumber]

      ##
      # :attr_reader:
      # Public: A list of emails associated with the account by the financial
      # institution; see IdentityEmail object for fields.
      property :emails, coerce: Array[IdentityEmail]

      ##
      # :attr_reader:
      # Public: Data about the various addresses associated with the account
      # by the financial institution; see IdentityAddress object for fields.
      property :addresses, coerce: Array[IdentityAddress]
    end

    # Public: A representation of an asset report balance.
    class AssetReportBalance < BaseModel
      ##
      # :attr_reader:
      # Public: The available balance as reported by the financial institution.
      # This is usually, but not always, the current balance less any
      # outstanding holds or debits that have not yet posted to the account.
      property :available

      ##
      # :attr_reader:
      # Public: The total amount of funds in the account.
      property :current

      ##
      # :attr_reader:
      # Public: The ISO currency code of the transaction, either USD or CAD.
      # Always nil if unofficial_currency_code is non-nil.
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The unofficial currency code associated with the transaction.
      # Always nil if iso_currency_code is non-nil.
      property :unofficial_currency_code
    end

    # Public: A representation of an asset report historical balance.
    class AssetReportHistoricalBalance < BaseModel
      ##
      # :attr_reader:
      # Public: The date of the calculated historical balance.
      property :date

      ##
      # :attr_reader:
      # Public: The total amount of funds in the account, calculated from the
      # current balance in the balance object by subtracting inflows and adding
      # back outflows according to the posted date of each.
      property :current

      ##
      # :attr_reader:
      # Public: The ISO currency code of the transaction, either USD or CAD.
      # Always nil if unofficial_currency_code is non-nil.
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The unofficial currency code associated with the transaction.
      # Always nil if iso_currency_code is non-nil.
      property :unofficial_currency_code
    end

    # Public: A representation of an asset report transaction.
    class AssetReportTransaction < BaseModel
      ##
      # :attr_reader:
      # Public: Plaid's unique identifier for the account.
      property :account_id

      ##
      # :attr_reader:
      # Public: Plaid's unique identifier for the transaction.
      property :transaction_id

      ##
      # :attr_reader:
      # Public: For pending transactions, Plaid returns the date the
      # transaction occurred; for posted transactions, Plaid returns the date
      # the transaction posts; both dates are returned in an ISO 8601 format
      # (YYYY-MM-DD).
      property :date

      ##
      # :attr_reader:
      # Public: The string returned by the financial institution to describe
      # the transaction.
      property :original_description

      ##
      # :attr_reader:
      # Public: When true, identifies the transaction as pending or unsettled;
      # pending transaction details (description, amount) may change before
      # they are settled.
      property :pending

      ##
      # :attr_reader:
      # Public: The settled dollar value; positive values when money moves out
      # of the account, negative values when money moves in.
      property :amount

      ##
      # :attr_reader:
      # Public: The ISO currency code of the transaction, either USD or CAD.
      # Always nil if unofficial_currency_code is non-nil.
      property :iso_currency_code

      ##
      # :attr_reader:
      # Public: The unofficial currency code associated with the transaction.
      # Always nil if iso_currency_code is non-nil.
      property :unofficial_currency_code

      ##
      # :attr_reader: Public: The String account owner (or nil). This field
      # only appears in an Asset Report with Insights.
      property :account_owner

      ##
      # :attr_reader: Public: The Array of String category (or nil). This field
      # only appears in an Asset Report with Insights. E.g. ["Payment", "Credit
      # Card"].
      property :category

      ##
      # :attr_reader: Public: The String category_id (or nil). This field only
      # appears in an Asset Report with Insights. E.g. "16001000".
      property :category_id

      ##
      # :attr_reader: Public: The String date of the transaction (or nil). This
      # field only appears in an Asset Report with Insights.
      property :date_transacted

      ##
      # :attr_reader: Public: The location where transaction occurred
      # (TransactionLocation). This field only appears in an Asset Report with
      # Insights.
      property :location, coerce: TransactionLocation

      ##
      # :attr_reader: Public: The String transaction name (or nil). This field
      # only appears in an Asset Report with Insights. E.g. "CREDIT CARD 3333
      # PAYMENT *//".
      property :name

      ##
      # :attr_reader: Public: The payment meta information
      # (TransactionPaymentMeta). This field only appears in an Asset Report
      # with Insights.
      property :payment_meta, coerce: TransactionPaymentMeta

      ##
      # :attr_reader: Public: The String pending transaction ID (or nil). This
      # field only appears in an Asset Report with Insights.
      property :pending_transaction_id

      ##
      # :attr_reader: Public: The String transaction type (or nil). E.g.
      # "special", or "place". This field only appears in an Asset Report with
      # Insights.
      property :transaction_type
    end

    # Public: A representation of an asset report account.
    class AssetReportAccount < BaseModel
      ##
      # :attr_reader:
      # Public: Plaid's unique identifier for the account.
      property :account_id

      ##
      # :attr_reader:
      # Public: The last 2-5 digits of the account's number.
      property :mask

      ##
      # :attr_reader:
      # Public: The name of the account, either assigned by the user or by the
      # financial institution itself.
      property :name

      ##
      # :attr_reader:
      # Public: The official name of the account as given by the financial
      # institution.
      property :official_name

      ##
      # :attr_reader:
      # Public: The primary type of the account (e.g., "depository").
      property :type

      ##
      # :attr_reader:
      # Public: The secondary type of the account (e.g., "checking").
      property :subtype

      ##
      # :attr_reader:
      # Public: Data returned by the financial institution about the account
      # owner or owners; see AssetReportOwner object for fields.
      property :owners, coerce: Array[AssetReportOwner]

      ##
      # :attr_reader:
      # Public: Data about the various balances on the account; see
      # AssetReportBalance object for fields.
      property :balances, coerce: AssetReportBalance

      ##
      # :attr_reader:
      # Public: Calculated data about the historical balances on the account;
      # see AssetReportHistoricalBalance object for fields.
      property :historical_balances, coerce: Array[AssetReportHistoricalBalance]

      ##
      # :attr_reader:
      # Public: Data about the transactions.
      property :transactions, coerce: Array[AssetReportTransaction]

      ##
      # :attr_reader:
      # Public: The duration of transaction history available for this Item,
      # typically defined as the time since the date of the earliest
      # transaction in that account.
      property :days_available
    end

    # Public: A representation of an asset report item.
    class AssetReportItem < BaseModel
      ##
      # :attr_reader:
      # Public: Plaid's unique identifier for the Item.
      property :item_id

      ##
      # :attr_reader:
      # Public: The full financial institution name associated with the Item.
      property :institution_name

      ##
      # :attr_reader:
      # Public: The financial institution associated with the Item.
      property :institution_id

      ##
      # :attr_reader:
      # Public: The date and time when this Item's data was retrieved from the
      # financial institution.
      property :date_last_updated

      ##
      # :attr_reader:
      # Public: Data about each of the accounts open on the Item; see Account
      # object for fields.
      property :accounts, coerce: Array[AssetReportAccount]
    end

    # Public: A representation of an asset report user.
    class AssetReportUser < BaseModel
      ##
      # :attr_reader:
      # Public: An identifier you determine and submit for the user.
      property :client_user_id

      ##
      # :attr_reader:
      # Public: The user's first name.
      property :first_name

      ##
      # :attr_reader:
      # Public: The user's middle name.
      property :middle_name

      ##
      # :attr_reader:
      # Public: The user's last name.
      property :last_name

      ##
      # :attr_reader:
      # Public: The user's social security number. Format:
      # "\d\d\d-\d\d-\d\d\d\d".
      property :ssn

      ##
      # :attr_reader:
      # Public: The user's phone number Format:
      # "+{country_code}{area code and subscriber number}", e.g.
      # "+14155555555" (known as E.164 format)
      property :phone_number

      ##
      # :attr_reader:
      # Public: The user's email address.
      property :email
    end

    # Public: A representation of an asset report.
    class AssetReport < BaseModel
      ##
      # :attr_reader:
      # Public: Plaid's unique identifier for this asset report.
      property :asset_report_id

      ##
      # :attr_reader:
      # Public: An identifier you determine and submit for the Asset Report.
      property :client_report_id

      ##
      # :attr_reader:
      # Public: The date and time when the Asset Report was created.
      property :date_generated

      ##
      # :attr_reader:
      # Public: The duration of transaction history you requested.
      property :days_requested

      ##
      # :attr_reader:
      # Public: Data submitted by you about the user whose Asset Report is
      # being compiled; see AssetReportUser object for fields.
      property :user, coerce: AssetReportUser

      ##
      # :attr_reader:
      # Public: Data returned by Plaid about each of the Items included in the
      # Asset Report; see AssetReportItem object for fields.
      property :items, coerce: Array[AssetReportItem]
    end

    # Public: A representation of an eligibility for the Public Service Loan
    # Forgiveness program.
    class PSLFStatus < BaseModel
      ##
      # :attr_reader:
      # Public: The estimated date borrower will have completed 120 qualifying
      # monthly payments.
      property :estimated_eligibility_date

      ##
      # :attr_reader:
      # Public: The number of qualifying payments that have been made.
      property :payments_made

      ##
      # :attr_reader:
      # Public: The number of qualifying payments that are remaining.
      property :payments_remaining
    end

    # Public: A representation of the status of a student loan.
    class StudentLoanStatus < BaseModel
      ##
      # :attr_reader:
      # Public: The status of the loan, e.g. "repayment", "deferment",
      # "forbearance".
      property :type

      ##
      # :attr_reader:
      # Public: The date the status expires.
      property :end_date
    end

    # Public: A representation of a student loan repayment plan.
    class StudentLoanRepaymentPlan < BaseModel
      ##
      # :attr_reader:
      # Public: The type of repayment plan, e.g., "standard", "income".
      property :type

      ##
      # :attr_reader:
      # Public: The full name of the repayment plan, e.g. "Standard Repayment".
      property :description
    end

    # Public: A representation of a student loan servicer address.
    class StudentLoanServicerAddress < BaseModel
      ##
      # :attr_reader:
      # Public: The full city name
      property :city

      ##
      # :attr_reader:
      # Public: The ISO 3166-1 alpha-2 country code
      property :country

      ##
      # :attr_reader:
      # Public: The postal code.
      property :postal_code

      ##
      # :attr_reader:
      # Public: The region or state.
      property :region

      ##
      # :attr_reader:
      # Public: The full street address.
      property :street
    end

    # Public: A representation of a student loan liability.
    class StudentLoanLiability < BaseModel
      ##
      # :attr_reader:
      # Public: The String account ID. E.g.
      # "vzeNDwK7KQIm4yEog683uElbp9GRLEFXGK98D".
      property :account_id

      ##
      # :attr_reader:
      # Public: The account number of the loan.
      property :account_number

      ##
      # :attr_reader:
      # Public: The dates on which loaned funds were disbursed or will be
      # disbursed. These are often in the past.
      property :disbursement_dates

      ##
      # :attr_reader:
      # Public: The date when the student loan is expected to be paid off.
      property :expected_payoff_date

      ##
      # :attr_reader:
      # Public: The guarantor of the student loan.
      property :guarantor

      ##
      # :attr_reader:
      # Public: The interest rate on loans shown as a percentage.
      property :interest_rate_percentage

      ##
      # :attr_reader:
      # Public: True if a payment is currently overdue.
      property :is_overdue

      ##
      # :attr_reader:
      # Public: The amount of the last payment.
      property :last_payment_amount

      ##
      # :attr_reader:
      # Public: The date of the last payment.
      property :last_payment_date

      ##
      # :attr_reader:
      # Public: The outstanding balance on the last statement.
      property :last_statement_balance

      ##
      # :attr_reader:
      # Public: The date the last statement was issued.
      property :last_statement_issue_date

      ##
      # :attr_reader:
      # Public: The status of the loan, e.g. "Repayment", "Deferment",
      # "Forbearance".
      property :loan_status, coerce: StudentLoanStatus

      ##
      # :attr_reader:
      # Public: The type of loan, e.g., "Consolidation Loans".
      property :loan_name

      ##
      # :attr_reader:
      # Public: The minimum payment due for the next billing cycle.
      property :minimum_payment_amount

      ##
      # :attr_reader:
      # Public: The due date for the next payment.
      property :next_payment_due_date

      ##
      # :attr_reader:
      # Public: The date on which the loan was initially lent.
      property :origination_date

      ##
      # :attr_reader:
      # Public: The original principal balance of the loan.
      property :origination_principal_amount

      ##
      # :attr_reader:
      # Public: The dollar amount of the accrued interest balance.
      property :outstanding_interest_amount

      ##
      # :attr_reader:
      # Public: The relevant account number that should be used to reference
      # this loan for payments. This is sometimes different from
      # account_number.
      property :payment_reference_number

      ##
      # :attr_reader:
      # Public: Information about the student's eligibility in the Public
      # Service Loan Forgiveness program.
      property :pslf_status, coerce: PSLFStatus

      ##
      # :attr_reader:
      # Public: Information about the repayment plan.
      property :repayment_plan, coerce: StudentLoanRepaymentPlan

      ##
      # :attr_reader:
      # Public: The sequence number of the student loan.
      property :sequence_number

      ##
      # :attr_reader:
      # Public: The servicer address for which payments should be sent.
      property :servicer_address, coerce: StudentLoanServicerAddress

      ##
      # :attr_reader:
      # Public: The year to date (YTD) interest paid.
      property :ytd_interest_paid

      ##
      # :attr_reader:
      # Public: The year to date (YTD) principal paid.
      property :ytd_principal_paid
    end

    # Public: A representation of a credit card liability APR
    class CreditCardLiabilityAPRs < BaseModel
      ##
      # :attr_reader:
      # Public: Annual Percentage Rate applied.
      property :apr_percentage

      ##
      # :attr_reader:
      # Public: Enumerated response from the following options:
      # "balance_transfer_apr", "cash_apr", "purchase_apr", or
      # "special".
      property :apr_type

      ##
      # :attr_reader:
      # Public: Amount of money that is subjected to the APR if a
      # balance was carried beyond payment due date. How it is
      # calculated can vary by card issuer. It is often calculated as
      # an average daily balance.
      property :balance_subject_to_apr

      ##
      # :attr_reader:
      # Public: Amount of money charged due to interest from last
      # statement.
      property :interest_charge_amount
    end

    # Public: A representation of a credit card liability
    class CreditCardLiability < BaseModel
      ##
      # :attr_reader:
      # Public: The ID of the account that this liability belongs to.
      property :account_id

      ##
      # :attr_reader:
      # Public: See the APR object schema
      property :aprs, coerce: Array[CreditCardLiabilityAPRs]

      ##
      # :attr_reader:
      # Public: true if a payment is currently overdue.
      property :is_overdue

      ##
      # :attr_reader:
      # Public: The amount of the last payment.
      property :last_payment_amount

      ##
      # :attr_reader:
      # Public: The date of the last payment.
      property :last_payment_date

      ##
      # :attr_reader:
      # Public: The outstanding balance on the last statement.
      property :last_statement_balance

      ##
      # :attr_reader:
      # Public: The date of the last statement.
      property :last_statement_issue_date

      ##
      # :attr_reader:
      # Public: The minimum payment due for the next billing cycle.
      property :minimum_payment_amount

      ##
      # :attr_reader:
      # Public: The due date for the next payment. The due date is null
      # if a payment is not expected.
      property :next_payment_due_date
    end

    # Public: A representation of someone's liabilities of all types.
    class Liabilities < BaseModel
      include Hashie::Extensions::IgnoreUndeclared

      ##
      # :attr_reader:
      # Public: Student loan liabilities associated with the item.
      property :student, coerce: Array[StudentLoanLiability]

      ##
      # :attr_reader:
      # Public: Credit card liabilities associated with the item.
      property :credit, coerce: Array[CreditCardLiability]
    end

    # Public: A representation of a payment amount.
    class PaymentAmount < BaseModel
      ##
      # :attr_reader:
      # Public: Currency for the payment amount.
      property :currency

      ##
      # :attr_reader:
      # Public: Value of the payment amount.
      property :value
    end

    # Public: A representation of a payment amount.
    class PaymentSchedule < BaseModel
      ##
      # :attr_reader:
      # Public: Interval for the standing order.
      property :interval

      ##
      # :attr_reader:
      # Public: Day or the week or day of the month to execute
      # the standing order.
      property :interval_execution_day

      ##
      # :attr_reader:
      # Public: Start date for the standing order.
      property :start_date
    end

    # Public: A representation of a payment amount.
    class PaymentRecipientAddress < BaseModel
      ##
      # :attr_reader:
      # Public: Street name.
      property :street

      ##
      # :attr_reader:
      # Public: City.
      property :city

      ##
      # :attr_reader:
      # Public: Postal code.
      property :postal_code

      ##
      # :attr_reader:
      # Public: Country.
      property :country
    end

    # Public: A representation of a payment recipient BACS number.
    class PaymentRecipientBACS < BaseModel
      ##
      # :attr_reader:
      # Public: The String account number. E.g. "66374958".
      property :account

      ##
      # :attr_reader:
      # Public: The String sort code. E.g. "089999".
      property :sort_code
    end

    # Public: A representation of a payment recipient.
    class PaymentRecipient < BaseModel
      ##
      # :attr_reader:
      # Public: The recipient ID.
      property :recipient_id

      ##
      # :attr_reader:
      # Public: The recipient name.
      property :name

      ##
      # :attr_reader:
      # Public: The recipient IBAN.
      property :iban

      ##
      # :attr_reader:
      # Public: The recipient BACS number .
      property :bacs, coerce: PaymentRecipientBACS

      ##
      # :attr_reader:
      # Public: The recipient address.
      property :address, coerce: PaymentRecipientAddress
    end

    # Public: A representation of a payment.
    class Payment < BaseModel
      ##
      # :attr_reader:
      # Public: The payment ID.
      property :payment_id

      ##
      # :attr_reader:
      # Public: The payment token.
      property :payment_token

      ##
      # :attr_reader:
      # Public: The payment reference.
      property :reference

      ##
      # :attr_reader:
      # Public: The payment amount.
      property :amount, coerce: PaymentAmount

      ##
      # :attr_reader:
      # Public: The payment schedule.
      property :schedule, coerce: PaymentSchedule

      ##
      # :attr_reader:
      # Public: The payment's status.
      property :status

      ##
      # :attr_reader:
      # Public: The last status update time for payment.
      property :last_status_update

      ##
      # :attr_reader:
      # Public: The payment token's expiration time.
      property :payment_token_expiration_time

      ##
      # :attr_reader:
      # Public: The recipient ID for payment.
      property :recipient_id
    end

    # Public: Metadata associated with a link token.
    class LinkTokenMetadata < BaseModel
      ##
      # :attr_reader:
      # Public: List of products associated with the link token.
      property :initial_products

      ##
      # :attr_reader:
      # Public: The webhook associated with the link token.
      property :webhook

      ##
      # :attr_reader:
      # Public: The country codes associated with the link token.
      property :country_codes

      ##
      # :attr_reader:
      # Public: The language associated with the link token.
      property :language

      ##
      # :attr_reader:
      # Public: The account filters associated with the link token.
      property :account_filters

      ##
      # :attr_reader:
      # Public: The redirect URI associated with the link token.
      property :redirect_uri

      ##
      # :attr_reader:
      # Public: The client name associated with the link token.
      property :client_name
    end

    # Public: A representation of a payment amount.
    class WebhookVerificationKey < BaseModel
      ##
      # :attr_reader:
      # Public: alg.
      property :alg

      ##
      # :attr_reader:
      # Public: created_at.
      property :created_at

      ##
      # :attr_reader:
      # Public: crv.
      property :crv

      ##
      # :attr_reader:
      # Public: expired_at.
      property :expired_at

      ##
      # :attr_reader:
      # Public: kid.
      property :kid

      ##
      # :attr_reader:
      # Public: kty.
      property :kty

      ##
      # :attr_reader:
      # Public: use.
      property :use

      ##
      # :attr_reader:
      # Public: x.
      property :x

      ##
      # :attr_reader:
      # Public: y.
      property :y
    end
  end
end
