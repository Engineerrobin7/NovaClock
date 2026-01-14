I've identified the root cause of the problem. Your repository contains large files in the `build` directory that were committed in the past. Even though these files might be ignored now, they still exist in the repository's history, and that's why the push is failing.

To fix this, you need to rewrite the history of your repository to remove the `build` directory. The recommended tool for this is `git filter-repo`.

**IMPORTANT: This is a destructive operation that will rewrite the history of your repository. Please back up your repository before proceeding.**

Here are the steps you need to take:

1.  **Install `git-filter-repo`**. If you don't have it installed, you can install it using pip:
    ```
    pip install git-filter-repo
    ```

2.  **Run `git-filter-repo` to remove the `build` directory**. In your terminal, at the root of your repository, run the following command:
    ```
    git filter-repo --path build --invert-paths
    ```

3.  **Push the changes to your remote repository**. After the history is rewritten, you will need to force push the changes:
    ```
    git push origin master --force
    ```

After these steps, your repository should be clean of the large files in the `build` directory, and you should be able to push your changes.
