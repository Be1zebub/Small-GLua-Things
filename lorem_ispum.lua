local LOREM_ISPUM = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Suspendisse rutrum accumsan elit vel auctor.
Praesent sit amet aliquam turpis.
Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae.
Maecenas non erat ut elit sodales commodo.
Nam gravida ipsum quis nulla tempus, quis pulvinar augue tristique.
Nulla massa odio, imperdiet non ultricies tincidunt, viverra sed lorem.
Nulla elementum sapien ut commodo aliquet.
Pellentesque iaculis turpis tellus, eget laoreet augue condimentum vel.
Quisque at risus rhoncus, facilisis tellus nec, tristique dolor.
Maecenas cursus magna eget imperdiet laoreet.]]

return function(min_len, max_len)
	max_len = max_len or min_len

	local len = math.random(min_len, max_len)

	local last_char = LOREM_ISPUM:sub(len, len)
	while not (last_char == " " or last_char == ".") do
		len = len - 1
		last_char = LOREM_ISPUM:sub(len, len)
	end 

	return LOREM_ISPUM:sub(1, len)
end
