class TransactionsController < ApplicationController
  #2 methods - one to create transaction, one to arrange pickup
  def create
    book = Book.find_by!(slug: params[:slug])
    #create sale to be processed with state
    sale = book.sales.create(
          amount: book.price,
          buyer_email: current_user.email,
          seller_email: book.user.email,
          stripe_token: params[:stripeToken]
      )
    sale.process!
    # token = params[:stripeToken]

    #begin processing payment
    # begin
    #   charge = Stripe::Charge.create(
    #         amount: book.price,
    #         currency: "usd",
    #         card: token,
    #         description: current_user.email
    #     )

    #   #create @sale and buyer_email and redirect user to pickup url
    #   @sale = book.sales.create!(buyer_email: current_user.email)
    if sale.finished?
      redirect_to pickup_url(guid: sale.guid)
    else
      #rescue card errors
    # rescue Stripe::CardError => e
    #   @error = e
      redirect_to book_path(book), notice: @error
    end
    # end
  end

  #Handle pickup of book by the generated UUID
  def pickup
    @sale = Sale.find_by!(guid: params[:guid])
    @book = @sale.book
  end
end
