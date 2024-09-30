#!/bin/bash

# The UUID of your external drive
DRIVE_UUID="6a664797-e80f-4011-82dd-860d4b9b4a55"

# Mount point
MOUNT_POINT="/mnt/immich_external"

# Function to check if the drive is connected
check_drive_connected() {
    if lsblk -no UUID | grep -q "$DRIVE_UUID"; then
        return 0
    else
        return 1
    fi
}

# Function to check if the mount is already in fstab
check_fstab() {
    if grep -q "$DRIVE_UUID" /etc/fstab; then
        return 0
    else
        return 1
    fi
}

# Create the mount point
sudo mkdir -p "$MOUNT_POINT"

# Check if the drive is connected
if ! check_drive_connected; then
    echo "The drive with UUID $DRIVE_UUID is not connected. Please connect the drive and run the script again."
    exit 1
fi

# Check if the mount is already in fstab
if check_fstab; then
    echo "The drive is already in fstab. Skipping fstab modification."
else
    # Backup the current fstab file
    sudo cp /etc/fstab /etc/fstab.backup

    # Add the new mount to fstab
    echo "UUID=$DRIVE_UUID $MOUNT_POINT auto defaults,nofail 0 2" | sudo tee -a /etc/fstab
    echo "Added new mount to fstab."
fi

# Attempt to mount the drive
sudo mount -a

# Check if the mount was successful
if mountpoint -q "$MOUNT_POINT"; then
    echo "Drive mounted successfully at $MOUNT_POINT"

    # Create necessary folders for Immich
    sudo mkdir -p "$MOUNT_POINT/immich/library"
    sudo mkdir -p "$MOUNT_POINT/immich/postgres"

    echo "Automount setup complete. Your drive should now mount automatically at $MOUNT_POINT"
else
    echo "Failed to mount the drive. Please check your UUID and try again."
    if ! check_fstab; then
        # Restore the backup fstab only if we modified it
        sudo mv /etc/fstab.backup /etc/fstab
        echo "Restored original fstab."
    fi
fi

UPLOAD_LOCATION="$MOUNT_POINT/immich/library"
DB_DATA_LOCATION="$MOUNT_POINT/immich/postgres"

# Print the variables (you can use these in your docker-compose file)
echo "UPLOAD_LOCATION=$UPLOAD_LOCATION"
echo "DB_DATA_LOCATION=$DB_DATA_LOCATION"
npm i -g @immich/cli
docker-compose up -d