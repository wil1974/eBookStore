class TransactionsController < ApplicationController
  #2 methods - one to create transaction, one to arrange pickup
  def create
    book = Book.find_by!(slug: params[:slug])
    token = params[:stripeToken]

    #begin processing payment
    begin
      charge = Stripe::Charge.create(
            amount: book.price,
            currency: "usd",
            card: token,
            description: current_user.email
        )

      #create @sale and buyer_email and redirect user to pickup url
      @sale = book.sales.create!(buyer_email: current_user.email)
      redirect_to pickup_url(guid: @sale.guid)

      #rescue card errors
    rescue Stripe::CardError => e
      @error = e
      redirect_to book_path(book), notice: @error
    end
  end

  #Handle pickup of book by the generated UUID
  def pickup
    @sale = Sale.find_by!(guid: params[:guid])
    @book = @sale.book
  end
end
