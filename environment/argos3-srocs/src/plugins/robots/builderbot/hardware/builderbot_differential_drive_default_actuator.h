/**
 * @file <argos3/plugins/robots/builderbot/hardware/builderbot_differential_drive_default_actuator.h>
 *
 * @author Michael Allwright - <allsey87@gmail.com>
 */

#ifndef BUILDERBOT_DIFFERENTIAL_DRIVE_DEFAULT_ACTUATOR_H
#define BUILDERBOT_DIFFERENTIAL_DRIVE_DEFAULT_ACTUATOR_H

namespace argos {
   class CBuilderBotDifferentialDriveDefaultActuator;
}

struct iio_device;
struct iio_buffer;
struct iio_channel; 

#include <cmath>

#include <argos3/plugins/robots/generic/hardware/actuator.h>
#include <argos3/plugins/robots/builderbot/control_interface/ci_builderbot_differential_drive_actuator.h>

namespace argos {

   class CBuilderBotDifferentialDriveDefaultActuator : public CPhysicalActuator,
                                                       public CCI_BuilderBotDifferentialDriveActuator {

   public:

      /**
       * @brief Constructor.
       */
      CBuilderBotDifferentialDriveDefaultActuator();

      /**
       * @brief Destructor.
       */
      virtual ~CBuilderBotDifferentialDriveDefaultActuator();

      virtual void Init(TConfigurationNode& t_tree);

      virtual void Update();

      virtual void Reset();

      virtual void SetTargetVelocityLeft(Real f_target_velocity_left);

      virtual void SetTargetVelocityRight(Real f_target_velocity_right);

   private:

      SInt16 ConvertToRaw(Real f_metres_per_second) {
         static const Real fConversionFactor = 776.66922486569;
         return std::round(f_metres_per_second * fConversionFactor);
      }

      iio_device* m_psDevice;
      iio_buffer* m_psBuffer;
      iio_channel* m_psLeft; 
      iio_channel* m_psRight;

      Real m_fTargetVelocityLeft;
      Real m_fTargetVelocityRight;

      bool m_bUpdateReq;


   };
}

#endif
