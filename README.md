# Salsify - Line Server Problem

This is my submission for the Line Server Problem. The exercise documentation can e find here: <https://salsify.github.io/line-server.html>

The project consists in the creation and endpoint to retrive the content in a given line of a file.

## Initial Setup

As asked, you can find the files in the the only thing you need to have installed in your pc is docker and docker-compose. After that running this two commands should be enough to have the app running

```./build.sh```

```./run.sh <file_name>```

## Challenge approach

The first think I focused on when faced by the challenged was finding the **best metrics** to be able to answer the specified questions and have the best possible solution. Based on that, I've decided to measure the amount of freed objects, memory used and time consumed while running the find line algorithm.

After having the functions that allowed me to get this values, I've focussed on the test files. I've considered **8* different file sizes** (0.1, 0.5, 1, 5, 10, 50, 100 and 500 Mb) and 4 different file characteristics (files with big lines size, medium lines size, small lines size and finally only paragraphs files). Each of the files contained lines with random number of ASCII characters.

The first considered approach involved reading all the file and use the method readlines (<https://apidock.com/ruby/IO/readlines>) that will return an array with all file lines. This method proved to be very slow when the number of the lines was too big

The second approach brought much interesting results since it used much less memory an reached a result much faster. This is the case when using the method.each (<https://apidock.com/ruby/IO/each>) on IO object that.

I was having difficulties finding a better approach to the problem since this looked like it was working fine and I was trying to avoid using a database to store file information. I've though on compressing the file to use less memory, but the approach did not look feasible. Then I started using chunks and the results were not better than the ones using the io.each enumerator. Then, I came accross this <https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html> that reminded me that I could use pointers to get to a closer point to the line much faster.

With that I mind, I've created the final solution that is explained in the code comments and also in the questions answers

<https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html>

*In github I've only considered files up to 10mb because of the file sizes

## Questions

#### How does your system work

The final algorithm considers two situation:

* IO.each approach **if** *the specified number is smaller than 10000 and the mean number of char per line is smaller than the 512*

* Select which pointer should be selected to start reading the file and after being selected start reading with IO.each **otherwhise**

In order to have this initial decision, there needs to be a initial pre-processing of the file into account. That is performed in the

#### How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file

The algorithm would perform very well in this scenario. The only case it might take a longer time is if the line size is really huge.

#### What documentation, websites, papers, etc did you consult in doing this assignment

I've already talked of some documentation and posts but you can find all the list bellow. The approach I've considered is based on other people attempts, even though their solutions don't involve pre-processing of the file in question.

* <https://apidock.com/ruby/IO>

* <https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html>

* <http://smyck.net/2011/02/12/parsing-large-logfiles-with-ruby/>

* <https://felipeelias.github.io/ruby/2017/01/02/fast-file-processing-ruby.html>

#### What third-party libraries or other tools does the system use? How did you choose each library or framework you used

Since I've selected Ruby to provide the final solution, I've decided to use Ruby on Rails since it is the framework I've used the most in the last two and half years.

I've also used the pg gem to have access to a PostgreSQL using the Active Records. I've also used the rswag gem in order to have the API documentation and rspec-rails for the endpoint tests. I've used this set up since it is the one I'm familiar with and met the requirements of the application.

It is not a framework nor a library, but I've decided to use Docker in order to make sure that the application is running in the same conditions in every machine that runs it locally.

#### How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item

Programming and testing the application, I would say around 20 hours. However, I've spent quite some time thinking on a better solution to be applied for the challenge. There must a better solution for sure since in the bach, you can get the number of lines in a file incredibly fast. Nevertheless, I've not discover a better solution than the one presented.

If I had unlimited more time to spend on this, in a first instance I would tun the parameters considered, like chunk size on the. I would also check if there is a way to compress a file without losing information about the number of lines. Maybe with the files Iǘe created it would be more difficult since the strings are randomly generated.

Also, I'm not really satisfied with the tests I've performed. I would like to search some more testing options not only to simulate with different files, but also to perform multiple requests at once.  

#### If you were to critique your code, what would you have to say about it

I know that I've some things to lear in terms of best programming. My background is not pure Web Development but I really like it and I'm looking for the opportunity to work in a team that applies those practices so I can learn from them. More specifically, I think I might not be declaring functions in the best places or I could probably give better variable names.

## Final notes

Really enjoy doing this challenge! Hope you consider my solution appropriate. If there is any problem in the test process our there's any doubt I can clarify, just let me know.

Hope to be part of the team soon. Looking forward for the next meeting.
