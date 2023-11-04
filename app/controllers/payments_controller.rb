# frozen_string_literal: true

class PaymentsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    make_payment_result = MakePaymentService.call(product, current_user, params[:delivery])

    if make_payment_result[:status] == 'success'
      redirect_to :successful_payment_path, note: make_payment_result[:message]
    else
      redirect_to :failed_payment_path, note: make_payment_result[:message]
    end
  end
end
