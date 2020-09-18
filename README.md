# Salsify - Line Server Problem

This is my submission for the Line Server Problem (<https://salsify.github.io/line-server.html>)

The project consists in the creation and endpoint to retrieve the content in a given line of a file.

## Initial Setup

You can find the asked bash files in the project root folder. You need to have **docker** and **docker-compose** installed and run the following command lines to have the app up and running.

```./build.sh```

```./run.sh <file_name>```

## Challenge approach

The first think I focused on when faced by the challenged was finding the **best metrics** to be able to answer the asked questions and have the best solution I could achieve. Based on that, I've decided to measure the **memory used** and **time consumed** for each approach.

After having the functions that allowed me to get this values, I've focussed on the test files. I've considered **8* different file sizes** (0.1, 0.5, 1, 5, 10, 50, 100 and 500 Mb) and 4 different file characteristics (big , medium and small lines sizes and a file only paragraphs). Each of the files contained lines with random number of ASCII characters. For each file, I've considered a run looking for the first line, for a line in the middle and the last line. All the results are in the results.csv file.

The first considered approach involved reading all the file and use the method readlines (<https://apidock.com/ruby/IO/readlines>) that will return an array with all file lines. The evidence of the bad results can be seen in the image bellow. In the presented images, each dot corresponds to results on the different files.

![Read Lines](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/read_lines_graph.png)

This method proved to be very slow when the number of the lines was very big (only paragraphs files) in big files. As expected, it also proved to consume a lot of memory since it had to load all the file and create a huge array with all the file lines, getting incredibly high values of memory consumed when the file had only paragraphs.

The second approach brought much interesting results since it used much less memory and retrieved the correct line much faster. This is the case when using IO.each method (<https://apidock.com/ruby/IO/each>). This method takes bytes from the file until if find a line delimiter and then passes to the next block. This allows us to stopped the loop as soon as it reaches the line number we want, that's why it is much more efficient.

![Each Line](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/each_line_graph.png)

I was having difficulties finding a better approach to the problem, without making any kind of pre-processing. I've though on compressing the file to use less memory, but the approach did not look feasible. Then I started using chunks and the results were not better than the ones using the io.each enumerator. Then, I came across this post <https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html> that reminded me that I could use pointers to get to a closer point to the line much faster.

With that I mind, I've created the final solution using pre-processing to store the final line number you can find in each chunk of 4096 bytes. This solution is better explained in the code comments and also in the questions answers. The obtained results are presented in the image bellow the improvements are visible.

![Final Solution](https://teste-martinho-page.s3-eu-west-1.amazonaws.com/share/final_graph.png)

_***In github I've only included files up to 10mb because of the file sizes**_

## Questions

#### How does your system work

My final algorithm considers the IO.each methods, however, it decides whether it starts reading the file from the beginning or from the a closer point depending on the line number asked and the lines average number of characters. In the pre-processing step, it will get the file size and number of lines with a bash command. If the line asked is lower than 10000 and the average number of characters per line is lower than 512 (buffer size considered in the IO.each), it will start from the beginning of the file.

This step is important since the access to the database takes some time (0.1 to 0.2 ms), and it is quite faster to reach the line if it is a low number. The average number of chars per line is also considered since it could take a long time and consume a lot of memory if each line is very big.

The database considered stores the final line number you can find in each chunk of 4096 bytes. This is what will alow the navigation through the file by using the method IO.seek,allowing us to start reading the file really closer to the final line and retrieve the content to the user much faster. Also, it will decrease the chance of loading big lines into memory since it normally reads a very small portion of the file lines.

#### How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file

The algorithm would perform well in any of the presented scenarios since it would not loss much time searching for the correct spot to star reading the file. The worse case would be if the closest lines before the line we are looking for or even the line we are looking for was really huge since it would have to load it chunk by chunk into memory and that would require a lot of time and memory usage.

#### How will your system perform with 100 users? 10000 users? 1000000 users

I've not found a proper way to test the solution on this scenarios, but I would say the system would perform fairly well, since the memory consumed by each process would be relatively low and not all the users would be accessing the endpoint in the same point in time. If that was the case, a lot would depend on the machine RAM size, and ability to manage the active processes in place.

Since the obtained solution would require low memory consumption and fast processing, the system should work well under the usage of many different users. Nevertheless, if the file has very big lines, this would mean the system would easily collapse since the active memory used for each process would be very big, and only some requests made in the same time could result is some of them not getting a response in reasonable time, being possible to not even receive the final for time limit from the browser or the platform used for deploy.

#### What documentation, websites, papers, etc did you consult in doing this assignment

I've already talked of some documentation and posts but you can find the most important on this challenge here.

* <https://apidock.com/ruby/IO/each>

* <https://apidock.com/ruby/IO/readlines>

* <https://apidock.com/ruby/IO/read>

* <https://apidock.com/ruby/IO/seek>

* <https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html>

* <http://smyck.net/2011/02/12/parsing-large-logfiles-with-ruby/>

* <https://felipeelias.github.io/ruby/2017/01/02/fast-file-processing-ruby.html>

#### What third-party libraries or other tools does the system use? How did you choose each library or framework you used

Since I've selected Ruby to provide the final solution, I've decided to use Ruby on Rails since it is the framework I've used the most in the last two and half years.

I've also used the pg gem to have access to a PostgreSQL using the Active Records. I've also used the rswag gem in order to have the API documentation (<http://localhost:3000/api-docs/index.html>) and rspec-rails for the endpoint tests. I've used this set up since it is the one I'm familiar with and met the requirements of the application.

It is not a framework nor a library, but I've decided to use Docker in order to make sure that the application is running in the same conditions in every machine that runs it locally.

#### How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item

I would say around 20 hours between studying and programming and testing the application. However, I've spent quite some time thinking on a better solution to be applied for the challenge. There must be much better solution without using any database to store data since in the bach, you can get the number of lines in a file incredibly fast. Nevertheless, I've not discover a better solution than the one presented.

If I had unlimited more time to spend on this, in a first instance I would tun the parameters considered, like chunk size on the pre-processing and the conditions to decide from where should I start reading the file. I would also check if there is a way to compress a file without losing information about the number of lines. Maybe with the files I've created it would be more difficult since the strings are randomly generated, not corresponding to any word in any language.

Another interesting solution that would be faster and consume less memory from the server, would be sto store the number of bytes you have to cover until you reach each line. Would be a very similar solution to the one considered but would require only one iteration of the method IO.each, meaning less memory usage and processing time in most cases.

Also, I'm not satisfied with the tests I've performed. I would like to search some more testing options not only to simulate with different files, but also to perform multiple requests at once.  

#### If you were to critique your code, what would you have to say about it

I know that I've some things to learn in terms of best programming practices. My background is not pure Web Development but I really like it and I'm looking for the opportunity to work in a team that applies those practices so I can learn from them. More specifically, I think I might not be declaring functions and performing validations in the best places or I could probably give better variable names.

## Final notes

Really enjoy doing this challenge! Hope you consider my solution appropriate. If there is any problem in the test process our there's any doubt I can clarify, just let me know.

Hope to be part of the team soon. Looking forward for the next meeting.
