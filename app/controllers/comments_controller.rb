class CommentsController < ApplicationController
  def create
    @Post = Post.find(params[:post_id])
    @comment = @post.comment.build(params.require(:comment).permit(:body))
   

    if @comment.save 
    flash[:notice] = "Your comment was added."
    redirect_to post_path(@post)
    else
      render 'posts/show'
    end
  end 
end