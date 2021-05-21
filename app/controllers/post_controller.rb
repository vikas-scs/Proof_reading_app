class PostController < ApplicationController
	def index
   
  end
  def new
    @post = Post.new 
  end
  def show
    @post = Post.find(params[:id])
  end
  def edit
     @post = Post.find(params[:id])
  end
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "poast was added successfully." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
      @post = Post.find(params[:id])
      if @post.update(post_params)
      redirect_to post_path
    else
      render :edit
    end
  end
  def destroy
  	 @post = Post.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: "post was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  private
    def post_params
      params.require(:post).permit(:post, :status)
    end
end
