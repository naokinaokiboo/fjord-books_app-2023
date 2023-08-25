class CommentsController < ApplicationController
  def create
    comment = @commentable.comments.build(comment_params.merge(user_id: current_user.id))
    if comment.save
      redirect_to @commentable, notice: 'コメントが正常に投稿されました。'
    else
      render_show_template_of_commentable
    end
  end

  def destroy
    comment = @commentable.comments.find(params[:id])
    if comment.destroy
      redirect_to @commentable, notice: 'コメントが正常に削除されました。'
    else
      render_show_template_of_commentable
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
