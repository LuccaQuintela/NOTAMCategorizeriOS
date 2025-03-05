# Note 

Please make your own branch rather than us all merging to main. 

Also if you have a windows or linux, this probably will not run on your machine. 

# Instructions

Model files can easily exceed the 100 MB maximum file size limit that git imposes. To store and pull bigger files, we need to use Git Large File Storage. 

### Step 1: Install 

On your terminal, run:

```zsh 
brew install git-lfs
``` 

If you don't have HomeBrew installed, read documentation [here](https://docs.brew.sh/).

### Step 2: Pulling Large Files

Run `git clone https://github.com/LuccaQuintela/NOTAMCategorizeriOS` like you normally would to pull in everything in the normal git repo. 

Next, you need to run:

```zsh
git lfs pull
``` 

This fetches all the larger files. Also run this when there's been changes to the large files. 

### Adding your own large files

If you choose to add something to repo that needs to be added through Large File Storage, you need to make sure that `git-lfs` is tracking that file. To see what files are currently being tracked, you can check `.gitattributes`. To add files to it, you can either run `git lfs track "[FILE]"`, or add it to `.gitattributes` manually. 

Afterwards, it should track those files automatically when added to the staging area, but if you would like to double check, run: 

```zsh
git lfs ls-files
```

This will show what files are currently being tracked by `git-lfs`. 

If you want any more informaiton, the documenation for `git-lfs` can be found [here](https://git-lfs.com/).