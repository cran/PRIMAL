#-----------------------------------------------------------------------#
# Package: PaRametric sImplex Method for spArse Learning                #
# Dantzig_solver() : Solve given dantzig selector problem    #
# in parametric simplex method                                          #
#-----------------------------------------------------------------------#

#' Solve given Dantzig selector problem in parametric simplex method
#'
#' @param X \code{x} is an \code{n} by \code{d} data matrix
#' @param y \code{y} is a length \code{n} response vector
#' @param max_it This is the number of the maximum path length one would like to achieve. The default length is \code{50}.
#' @param lambda_threshold The parametric simplex method will stop when the calculated parameter is smaller than lambda. The default value is \code{0.01}.
#' @return
#' An object with S3 class \code{"primal"} is returned:
#' \item{data}{
#'   The \code{n} by \code{d} data matrix from the input
#' }
#' \item{response}{
#'   The length \code{n} response vector from the input
#' }
#' \item{beta}{
#'   A matrix of regression estimates whose columns correspond to regularization parameters for parametric simplex method.
#' }
#' \item{df}{
#'   The degree of freedom (number of nonzero coefficients) along the solution path.
#' }
#' \item{value}{
#'   The sequence of optimal value of the object function corresponded to the sequence of lambda.
#' }
#' \item{iterN}{
#'   The number of iteration in the program.
#' }
#' \item{lambda}{
#'   The sequence of regularization parameters \code{lambda} obtained in the program.
#' }
#' \item{type}{
#'   The type of the problem, such as \code{Dantzig} and \code{SparseSVM}.
#' }
#' @examples
#' ## Dantzig
#' ## We set X to be standard normal random matrix and generate Y using gaussian noise.
#' ## Generate the design matrix and coefficient vector
#' n = 100 # sample number
#' d = 250 # sample dimension
#' c = 0.5 # correlation parameter
#' s = 20  # support size of coefficient
#' set.seed(1024)
#' X = scale(matrix(rnorm(n*d),n,d)+c*rnorm(n))/sqrt(n-1)*sqrt(n)
#' beta = c(rnorm(s), rep(0, d-s))
#' ## Generate response using Gaussian noise, and solve the solution path
#' noise = rnorm(n)
#' Y = X%*%beta + noise
#' ## Dantzig selection solved with parametric simplex method
#' fit.dantzig = Dantzig_solver(X, Y, max_it = 100, lambda_threshold = 0.01)
#' ###lambdas used
#' print(fit.dantzig$lambda)
#' ## number of nonzero coefficients for each lambda
#' print(fit.dantzig$df)
#' ## Visualize the solution path
#' plot(fit.dantzig)
#' @seealso \code{\link{primal-package}}
#' @export
Dantzig_solver <- function(X, y, max_it = 50, lambda_threshold = 0.01) {
    begt <- Sys.time()
    n <- nrow(X)
    d <- ncol(X)
    t <- 0
    lambdalist <- rep(0, max_it)
    x_list <- matrix(0, d, max_it)
    y_list <- rep(0, max_it)
    str <- .C("Dantzig_api", as.integer(n), as.integer(d), as.double(t(X)), as.double(y),
              as.integer(max_it), as.double(lambda_threshold), as.integer(t),
              as.double(lambdalist), as.double(x_list), as.double(y_list), PACKAGE = "PRIMAL")
    t <- unlist(str[7])
    x_list <- matrix(unlist(str[9])[1:(d * t)], d, t)
    df <- c()
    for (i in 1:t) {
        df[i] <- sum(x_list[, i] != 0)
    }
    runt <- Sys.time() - begt
    ans <- list(type = "Dantzig",
                data = X,
                response = y,
                beta = Matrix(x_list),
                df = df,
                value = unlist(str[10])[1:t],
                iterN = t,
                lambda = unlist(str[8])[1:t],
                runtime = runt)
    class(ans) <- "primal"
    return(ans)
}


