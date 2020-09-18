# Salsify - Line Server Problem

This is my submission for the Line Server Problem (<https://salsify.github.io/line-server.html>)

The project consists in the creation and endpoint to retrieve the content in a given line of a file.

## Initial Setup

I've inserted theAs asked, you can find the files in the the only thing you need to have installed in your pc is **docker** and **docker-compose**. After that, simply run the commands bellow. The first one will be responsible for building the containers and the last to have the file pre processing done and make the application up.

```./build.sh```

```./run.sh <file_name>```

## Challenge approach

The first think I focused on when faced by the challenged was finding the **best metrics** to be able to answer the specified questions and have the best possible solution. Based on that, I've decided to measure the **amount of freed objects**, **memory used** and **time consumed** for each approach.

After having the functions that allowed me to get this values, I've focussed on the test files. I've considered **8* different file sizes** (0.1, 0.5, 1, 5, 10, 50, 100 and 500 Mb) and 4 different file characteristics (big , medium and small lines sizes and a file only paragraphs). Each of the files contained lines with random number of ASCII characters.

The first considered approach involved reading all the file and use the method readlines (<https://apidock.com/ruby/IO/readlines>) that will return an array with all file lines. The evidence of the bad results can be seen in the image bellow. In the presented images, each dot corresponds to results on the different files.

![Read Lines](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/read_lines_graph.png)

This method proved to be very slow when the number of the lines was very big (only paragraphs files). As expected, it also proved to consume a lot of memory since it had to load all the file and create this huge array with all the file lines, getting incredibly high values of memory consumed when the

The second approach brought much interesting results since it used much less memory an retrieved the correct line much faster. This is the case when using the method.each (<https://apidock.com/ruby/IO/each>) on IO object that. This works with and enumerator that will run over the file and inserting content into a buffer until it finds a "\n" char. After that, moves to the next iteration and the loop is stopped as soon as it reaches the line number.

![Each Line](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/each_line_graph.png)

I was having difficulties finding a better approach to the problem since this looked like it was working fine and I was trying to avoid using a database to store file information. I've though on compressing the file to use less memory, but the approach did not look feasible. Then I started using chunks and the results were not better than the ones using the io.each enumerator. Then, I came across this post <https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html> that reminded me that I could use pointers to get to a closer point to the line much faster.

With that I mind, I've created the final solution using pre-processing to store the final line number you can find in each chunk. This solution is better explained in the code comments and also in the questions answers. The obtained results are presented in the image bellow the improvements are visible.

![Final Solution](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/final_graph.png)

_*In github I've only considered files up to 10mb because of the file sizes_

## Questions

#### How does your system work

The final algorithm considers the IO.each methods, however, it decides whether it starts reading the file from the beginning or from the a closer point depending on the line number asked.

In the pre-processing step, I will get the file size and number of lines with a bash command. Based on those metrics, it will decide if it should start reading the file from the beginning or not. This step is important since the access to the database takes some time, and it is quite faster to reach the line if it is a low number. The average number of chars per line is also considered since it could take a long time to reach a low line number if each line is very big.

The database considered stores the final line number you can find in each chunk of 4096 (bytes). This is what will alow the navigation throw the file by using the method IO.seek. This will allow us to start reading the file really close to the final line and retrieve the content to the user much fast. Also, it will increase the chance of avoiding loading into memory really since it normally reads a very small portion of the file.

#### How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file

The algorithm would perform well in any of the presented scenarios since it would not loss much time searching for the correct spot to star reading the file. The worse case would be if a close the line or even the line qe are looking for was really huge since it would have to load it chunk by chunk into memory and that would reqyi.

#### How will your system perform with 100 users? 10000 users? 1000000 users

I've not found a proper way to test the solution on this scenarios, but I would say the system would perform fairly well, since the memory consumed by each process would be relatively low and not all the users would be accessing the endpoint in the same point in time. If that was the case, a lot would depend on the machine RAM size, since the amount of memory used would round the 0.5mb but this can reach the machine limit with this amount of users using this endpoint.

#### What documentation, websites, papers, etc did you consult in doing this assignment

I've already talked of some documentation and posts but you can find all the list bellow.

* <https://apidock.com/ruby/IO>

* <https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html>

* <http://smyck.net/2011/02/12/parsing-large-logfiles-with-ruby/>

* <https://felipeelias.github.io/ruby/2017/01/02/fast-file-processing-ruby.html>

#### What third-party libraries or other tools does the system use? How did you choose each library or framework you used

Since I've selected Ruby to provide the final solution, I've decided to use Ruby on Rails since it is the framework I've used the most in the last two and half years.

I've also used the pg gem to have access to a PostgreSQL using the Active Records. I've also used the rswag gem in order to have the API documentation and rspec-rails for the endpoint tests. I've used this set up since it is the one I'm familiar with and met the requirements of the application.

It is not a framework nor a library, but I've decided to use Docker in order to make sure that the application is running in the same conditions in every machine that runs it locally.

#### How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item

I would say around 20 hours between studying and programming and testing the application. However, I've spent quite some time thinking on a better solution to be applied for the challenge. There must be much better solution without using any database to store data since in the bach, you can get the number of lines in a file incredibly fast. Nevertheless, I've not discover a better solution than the one presented.

If I had unlimited more time to spend on this, in a first instance I would tun the parameters considered, like chunk size on the pre-processing and the conditions to decide from where should I start reading the file. I would also check if there is a way to compress a file without losing information about the number of lines. Maybe with the files I've created it would be more difficult since the strings are randomly generated, not corresponding to any word in any language.

Also, I'm not satisfied with the tests I've performed. I would like to search some more testing options not only to simulate with different files, but also to perform multiple requests at once.  

#### If you were to critique your code, what would you have to say about it

I know that I've some things to lear in terms of best programming. My background is not pure Web Development but I really like it and I'm looking for the opportunity to work in a team that applies those practices so I can learn from them. More specifically, I think I might not be declaring functions in the best places or I could probably give better variable names.

## Final notes

Really enjoy doing this challenge! Hope you consider my solution appropriate. If there is any problem in the test process our there's any doubt I can clarify, just let me know.

Hope to be part of the team soon. Looking forward for the next meeting.
