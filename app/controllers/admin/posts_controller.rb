module Admin
  class PostsController < ApplicationController
    def deleted
      @deleted_lost_items = LostItem.where(deleted: true)
      @deleted_found_items = FoundItem.where(deleted: true)
    end

    def restore
      post = LostItem.find_by(id: params[:id]) || FoundItem.find_by(id: params[:id])
      if post
        post.update(deleted: false)
        redirect_to admin_deleted_posts_path, notice: "Post restored successfully."
      else
        redirect_to admin_deleted_posts_path, alert: "Post not found."
      end
    end
  end
end