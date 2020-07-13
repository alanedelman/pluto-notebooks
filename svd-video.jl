### A Pluto.jl notebook ###
# v0.9.11

using Markdown
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.peek, el) ? Base.peek(el) : missing
        el
    end
end

# ╔═╡ fcac2038-b7aa-11ea-1320-355e0731afb4
using LinearAlgebra

# ╔═╡ d7eadad2-b7ad-11ea-22e3-f1e5ded42255
md"# Singular Value Decomposition

Lorem ipsum SVD est."

# ╔═╡ dfd0317e-b85f-11ea-3f2b-fd95c87a0a69
zeros(Float64, 0, 0)

# ╔═╡ d6f2ee1c-b7ad-11ea-0e1c-fb21a58c5711
md"## Step 1: upload your favorite image:"

# ╔═╡ 841551d2-b861-11ea-08de-c180ca50b9be
struct ImageInput
    use_camera::Bool
    default_url::AbstractString
    maxsize::Integer
end

# ╔═╡ 8c0caad4-b861-11ea-3aab-83e4d3718aa9
img = ImageInput(true, "asdf", 200)

# ╔═╡ 74cac824-b861-11ea-37e9-e97065879618
ph = """
<span class="pl-image">
<style>

.pl-image video {
	max-width: 250px;
}

.pl-image video.takepicture {
	animation: pictureflash 200ms linear;
}

@keyframes pictureflash {
	0% {
		filter: grayscale(1.0) contrast(2.0);
	}

	100% {
		filter: grayscale(0.0) contrast(1.0);
	}
}
</style>

<div id="video-container" title="Click to take a picture">
<video playsinline autoplay></video>
</div>

<script>
// mostly taken from https://github.com/fonsp/printi-static
// (by the same author)

const span = this.currentScript.parentElement
const video = span.querySelector("video")
const img = html`<img crossOrigin="anonymous">`

const maxsize = $(img.maxsize)

const send_source = (source, src_width, src_height) => {
	const scale = Math.min(1.0, maxsize / src_width, maxsize / src_height)

	const width = Math.floor(src_width * scale)
	const height = Math.floor(src_height * scale)

	const canvas = html`<canvas width=\${width} height=\${height}>`
	const ctx = canvas.getContext("2d")
	ctx.drawImage(source, 0, 0, width, height)

	span.value = {
		width: width,
		height: height,
		data: Array.from(ctx.getImageData(0, 0, width, height).data),
	}
	span.dispatchEvent(new CustomEvent("input"))
}


navigator.mediaDevices.getUserMedia({
	audio: false,
	video: {
		facingMode: "environment",
	},
}).then(function(stream) {

	window.stream = stream
	video.srcObject = stream
	window.cameraConnected = true
	video.controls = false
	video.play()
	video.controls = false

}).catch(function(error) {
	console.log(error)
});

var sending= false

span.querySelector("#video-container").onclick = function() {
	sending = !sending
}

setInterval(() => {
	if(sending){

		const cl = video.classList
		cl.remove("takepicture")
		void video.offsetHeight
		cl.add("takepicture")
		video.play()
		video.controls = false
		console.log(video)
		send_source(video, video.videoWidth, video.videoHeight)
	}
}, 200)

</script>
</span>
""" |> HTML;

# ╔═╡ 212d10d6-b7ae-11ea-1434-fb7d45aaf278
md"The (black-and-white) image data is now available as a Julia 2D array:"

# ╔═╡ 42578c50-b7ae-11ea-2f7d-6b8b3df44aed
md"This notebook defines a type `BWImage` that can be used to turn 2D Float arrays into a picture!"

# ╔═╡ 90715ff6-b7ae-11ea-3780-1d227049322c
md"You can use `img_data` like any other Julia 2D array! For example, here is the top left corner of your image:"

# ╔═╡ 7c8b8c96-b7ae-11ea-149d-61d29d35847c
md"## Step 2: running the SVD

The Julia standard library package `LinearAlgebra` contains a method to compute the SVD. "

# ╔═╡ 07834ab8-b7ba-11ea-0279-77179671d826
md"Let's look at the result."

# ╔═╡ 9765a090-b7b0-11ea-3c1f-e5a8ac58d7de
#[📚.U, 📚.S, 📚.V]

# ╔═╡ fe4c70fe-b7b0-11ea-232b-1996facd33a0
md"Let's verify the identity

$A = U \Sigma V^{\intercal}$"

# ╔═╡ 8e7cb972-b7b1-11ea-2c4d-ed583218740a
md"Are they equal?"

# ╔═╡ 4df00b20-b7b1-11ea-0836-41314f8a2d35
md"It looks like they are **not** equal - how come?

Since we are using a _computer_, the decomposition and multiplication both introduce some numerical errors. So instead of checking whether the reconstructed matrix is _equal_ to the original, we can check how _close_ they are to each other."

# ╔═╡ 2199d7b2-b7b2-11ea-2e86-95b23658a538
md"One way to quantify the _distance_ between two matrices is to look at the **point-wise difference**. If the **sum** of all differences is close to 0, the matrices are almost equal."

# ╔═╡ 489b7c9c-b7b1-11ea-3a54-87bd17341b2c
md"There are other ways to compare two matrices, such methods are called _**matrix norms**_."

# ╔═╡ a6dcc77c-b7b2-11ea-0c7d-d5686603d182
md"### The 👀-norm"

# ╔═╡ b15d683c-b7b2-11ea-1090-b392950bedb6
md"Another popular matrix norm is the **👀_-norm_**: you turn both matrices into a picture, and use your 👀 to see how close they are:"

# ╔═╡ 064d5a78-b7b3-11ea-399c-f968bf9c910a
md"""**How similar are these images?**  $(@bind 👀_dist html"<input>")"""

# ╔═╡ 2c7c8cdc-b7b3-11ea-166c-cfd232fd2004
👀_dist

# ╔═╡ 64e51904-b7b3-11ea-0f72-359d63261b21
md"In some applications, like _**image compression**_, this is the _most imporant norm_."

# ╔═╡ d2de4480-b7b0-11ea-143d-033dc76cf6bc
md"## Step 3: compression"

# ╔═╡ 79a01d50-b7b1-11ea-27ee-4161da276cde
md"Blabla"

# ╔═╡ 54f79f6e-b865-11ea-2f16-ff76fe1f14ed
@bind upload_data ph

# ╔═╡ c8f52288-b7a9-11ea-02b7-698ec1d06357
img_data = let
	# every 4th byte is the Red pixel value
	reds = UInt8.(upload_data["data"][1:4:end])
	# shuffle and flip to get it in the right shape
	( reshape(reds, (upload_data["width"], upload_data["height"]))') / 255.0
end;

# ╔═╡ a404b9f8-b7ab-11ea-0b07-a733a3c4f353
📚 = svd(img_data);

# ╔═╡ 1e866730-b7ac-11ea-3df1-9f7f92d504db
@bind keep HTML("<input type='range' max='50' value='10'>")

# ╔═╡ 9b18067e-b7b3-11ea-0372-d351201a0e7d
md"Showing the **first $(keep) singular pairs**."

# ╔═╡ 2fdd76dc-b7ce-11ea-12b1-59aa1c44ebbe
md"### Store fewer bytes"

# ╔═╡ 3bb96bf2-b7cc-11ea-377f-2d5d3f04e96d
#compressed_size(keep), uncompressed_size()

# ╔═╡ 906a267a-b7ca-11ea-1e73-a56b7e7c9115
#BWImage(Float16.(F.U)[:,1:keep] * Diagonal(Float16.(F.S[1:keep])) * Float16.(F.V)'[1:keep,:])

# ╔═╡ 444bc786-b7ce-11ea-0016-ff1fbb17d736
md"JPEG works in a similar way"

# ╔═╡ 1c55bd84-b7c9-11ea-0aa5-b95f58fae242
md"### Individual pairs"

# ╔═╡ 7485990a-b7af-11ea-10e4-53a3ab5dcea7
md"## Going further

More stuff to learn about SVD

To keep things simple (and dependency-free), this notebook only works with downscaled black-and-white images that you pick using the button. For **color**, **larger images**, or **images from your disk**, you should look into the [`Images.jl`](https://github.com/JuliaImages/Images.jl) package!"

# ╔═╡ 34de1bc0-b795-11ea-2cac-bbbc496133ad
begin
	struct BWImage
		data::Array{UInt8, 2}
	end
	function BWImage(data::Array{T, 2}) where T <: AbstractFloat
		BWImage(floor.(UInt8, clamp.(data * 255, 0, 255)))
	end
	
	import Base: show
	
	function show(io::IO, ::MIME"image/bmp", i::BWImage)

		height, width = size(i.data)
		datawidth = Integer(ceil(width / 4)) * 4

		bmp_header_size = 14
		dib_header_size = 40
		palette_size = 256 * 4
		data_size = datawidth * height * 1

		# BMP header
		write(io, 0x42, 0x4d)
		write(io, UInt32(bmp_header_size + dib_header_size + palette_size + data_size))
		write(io, 0x00, 0x00)
		write(io, 0x00, 0x00)
		write(io, UInt32(bmp_header_size + dib_header_size + palette_size))

		# DIB header
		write(io, UInt32(dib_header_size))
		write(io, Int32(width))
		write(io, Int32(-height))
		write(io, UInt16(1))
		write(io, UInt16(8))
		write(io, UInt32(0))
		write(io, UInt32(0))
		write(io, 0x12, 0x0b, 0x00, 0x00)
		write(io, 0x12, 0x0b, 0x00, 0x00)
		write(io, UInt32(0))
		write(io, UInt32(0))

		# color palette
		write(io, [[x, x, x, 0x00] for x in UInt8.(0:255)]...)

		# data
		padding = fill(0x00, datawidth - width)
		for y in 1:height
			write(io, i.data[y,:], padding)
		end
	end
end

# ╔═╡ 04c34a64-b7ac-11ea-0cc0-6709153eaf18
BWImage(
	📚.U[:,1:keep] * 
	Diagonal(📚.S[1:keep]) * 
	📚.V'[1:keep,:]
)

# ╔═╡ Cell order:
# ╟─d7eadad2-b7ad-11ea-22e3-f1e5ded42255
# ╠═dfd0317e-b85f-11ea-3f2b-fd95c87a0a69
# ╟─d6f2ee1c-b7ad-11ea-0e1c-fb21a58c5711
# ╠═841551d2-b861-11ea-08de-c180ca50b9be
# ╠═8c0caad4-b861-11ea-3aab-83e4d3718aa9
# ╠═74cac824-b861-11ea-37e9-e97065879618
# ╟─212d10d6-b7ae-11ea-1434-fb7d45aaf278
# ╠═c8f52288-b7a9-11ea-02b7-698ec1d06357
# ╟─42578c50-b7ae-11ea-2f7d-6b8b3df44aed
# ╟─90715ff6-b7ae-11ea-3780-1d227049322c
# ╟─7c8b8c96-b7ae-11ea-149d-61d29d35847c
# ╠═fcac2038-b7aa-11ea-1320-355e0731afb4
# ╠═a404b9f8-b7ab-11ea-0b07-a733a3c4f353
# ╟─07834ab8-b7ba-11ea-0279-77179671d826
# ╠═9765a090-b7b0-11ea-3c1f-e5a8ac58d7de
# ╟─fe4c70fe-b7b0-11ea-232b-1996facd33a0
# ╟─8e7cb972-b7b1-11ea-2c4d-ed583218740a
# ╟─4df00b20-b7b1-11ea-0836-41314f8a2d35
# ╟─2199d7b2-b7b2-11ea-2e86-95b23658a538
# ╟─489b7c9c-b7b1-11ea-3a54-87bd17341b2c
# ╟─a6dcc77c-b7b2-11ea-0c7d-d5686603d182
# ╟─b15d683c-b7b2-11ea-1090-b392950bedb6
# ╟─064d5a78-b7b3-11ea-399c-f968bf9c910a
# ╠═2c7c8cdc-b7b3-11ea-166c-cfd232fd2004
# ╟─64e51904-b7b3-11ea-0f72-359d63261b21
# ╟─d2de4480-b7b0-11ea-143d-033dc76cf6bc
# ╟─79a01d50-b7b1-11ea-27ee-4161da276cde
# ╠═54f79f6e-b865-11ea-2f16-ff76fe1f14ed
# ╠═1e866730-b7ac-11ea-3df1-9f7f92d504db
# ╟─9b18067e-b7b3-11ea-0372-d351201a0e7d
# ╠═04c34a64-b7ac-11ea-0cc0-6709153eaf18
# ╟─2fdd76dc-b7ce-11ea-12b1-59aa1c44ebbe
# ╠═3bb96bf2-b7cc-11ea-377f-2d5d3f04e96d
# ╠═906a267a-b7ca-11ea-1e73-a56b7e7c9115
# ╟─444bc786-b7ce-11ea-0016-ff1fbb17d736
# ╟─1c55bd84-b7c9-11ea-0aa5-b95f58fae242
# ╟─7485990a-b7af-11ea-10e4-53a3ab5dcea7
# ╠═34de1bc0-b795-11ea-2cac-bbbc496133ad
