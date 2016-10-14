#!/bin/bash
set -e

DIR=$(mktemp -d)
DEPLOYED_FILE="$(pwd)/deployed.txt"
SUBTREE_PREFIX="devops/ansible/roles/girder"
SUBTREE_DEST_REPO="git@github.com:girder/ansible-role-girder.git"
SUBTREE_DEST_BRANCH="master"

function cleanup_scratch {
    rm -rf "$DIR"
}
trap cleanup_scratch EXIT

pushd "$DIR"
git clone git@github.com:girder/girder.git .

if  [ -f "$DEPLOYED_FILE" ] && grep -q "$(git rev-parse HEAD)" "$DEPLOYED_FILE"; then
    # This revision has already been pushed to ansible-role-girder
    echo "Already deployed $(git rev-parse HEAD) to ansible-role-girder."
    exit 0
else
    git subtree push --prefix="$SUBTREE_PREFIX" "$SUBTREE_DEST_REPO" "$SUBTREE_DEST_BRANCH"
    git rev-parse HEAD >> "$DEPLOYED_FILE"
fi
