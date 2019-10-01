class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    # setting up the '@all_ratings' variable
    @all_ratings = Movie.get_ratings
    
    # saving the sort to the session if the user's selected a sort method
    if params[:sort_method].present?
      session[:sort_method] = params[:sort_method]
    end
    
    # saving the selected ratings to the session if the user's selected ratings
    if params[:ratings].present?
      @selected_ratings = params[:ratings]
      session[:selected_ratings] = @selected_ratings
    end
    
    # if the user is travelling back to a page, and selected ratings have already been set, then pull the settings from the saved session and redirect the user to the right settings
    if (session[:selected_ratings]) && params[:sort_method].blank? && params[:ratings].blank?
      @sort_method = session[:sort_method]
      @selected_ratings = session[:selected_ratings]
      redirect_to movies_path({order_by: @sort_method, ratings: @selected_ratings})
    end
    
    @movies = Movie.all
    
    # query movies that have the selected rating
    if session[:selected_ratings]
      @movies = @movies.select{|movie| session[:selected_ratings].include? movie.rating}
    end

    # sorting by header property
    if params[:sort_method] == "title"
      @movies = Movie.order("title asc")
      @movie_header = "hilite"
    elsif params[:sort_method] == "release_date"
      @movies = Movie.order("release_date asc")
      @date_header = "hilite"
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
