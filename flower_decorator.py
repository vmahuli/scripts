import os

def flowerDecorator(vasel):
    def newFlowerVase(n):
        print("We are decorating the flower vase.")
        print("You wanted to keep %d flowers in the vase." % n)

        vasel(n)

        print("Our decoration is done")

    return newFlowerVase


@flowerDecorator
def flowerVase(n):
    print("We have a flower vase.")


flowerVase(6)
