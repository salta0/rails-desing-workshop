# frozen_string_literal: true

class ProcessCloudPaymentService
  CURRENCY = 'RUB'
  CLOUD_PAYMENT_SUCCESS = 'complited'

  def initialize(user:, product:)
    @user = user
    @product = product
  end

  def call
    process_payment
    product_access = create_product_access(user:, product:)
    send_product_access_email(product_access)
    { status: 'success', message: 'Payment complete' }
  rescue ServiceErrors::CloudPaymentError
    # log_error

    { status: 'fail', message: 'Payment failed' }
  end

  private

  attr_reader :product, :user

  def process_payment
    res = CloudPayment.proccess(
      user_uid: current_user.cloud_payments_uid,
      amount_cents: product.amount * 100,
      currency: CURRENCY
    )
    return if res[:status] == CLOUD_PAYMENT_SUCCESS

    raise ServiceErrors::CloudPaymentError.new(product:, user:, status: res[:status])
  end

  def create_product_access
    ProductAccess.create(user:, product:)
  end

  def send_product_access_email(product_access)
    OrderMailer.product_access_email(product_access).deliver_later
  end
end
