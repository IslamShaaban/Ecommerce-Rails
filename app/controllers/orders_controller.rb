class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @orders = Order.where(user_id: current_user.id).where.not(state: "inCart").order(created_at: :desc)
  end
    
  def edit
    @order = Order.find_by(id: params[:id], state: "inCart")
  end
    
  ## Put in Order
  def update
    @order = Order.find(params[:id])
    @orderprod = OrderProduct.where(order_id: @order.id)
    @orderprod.each do |ordprod|
      ordprod.update(state: "pending")
      (ordprod.product).update(quantity: ordprod.product.quantity-ordprod.quantity)
    end
    if @order.update(state: "pending")
      redirect_to orders_path, notice: 'put in Order'
    else
      redirect_to request.referrer, alert: 'Form inputs not valid please check them'
    end
  end

  def destroy
    if @order.state == "inCart"
      @orderprod = OrderProduct.find_by(order_id: @order.id)
      @orderprod.destroy
      @order.destroy
      redirect_to mycart_path, notice: 'Removed successfully'
    else
      redirect_to orders_url, notice: 'Order didnt destroy.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end
    # Only allow a list of trusted parameters through.
    def order_params
      params.fetch(:order, {}).permit(:id,:quantity,:address, :billing)
    end

    def order_address
      Address.create(address: params[:address], billing: params[:billing], user_id: current_user.id, order_id: @order.id)
    end

end