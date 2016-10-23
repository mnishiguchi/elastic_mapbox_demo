class ManagementsController < ApplicationController
  
  def index
    @managements = Management.all
  end

  def show
    @management = Management.find(params[:id])
  end
end
