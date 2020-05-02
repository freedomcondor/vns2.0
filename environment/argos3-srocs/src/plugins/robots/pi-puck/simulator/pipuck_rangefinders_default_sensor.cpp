/**
 * @file <argos3/plugins/robots/pi-puck/simulator/pipuck_rangefinders_default_sensor.cpp>
 *
 * @author Michael Allwright - <allsey87@gmail.com>
 */

#include "pipuck_rangefinders_default_sensor.h"

#include <argos3/core/utility/logging/argos_log.h>
#include <argos3/core/simulator/entity/composable_entity.h>
#include <argos3/core/simulator/entity/controllable_entity.h>
#include <argos3/core/simulator/entity/embodied_entity.h>
#include <argos3/core/simulator/physics_engine/physics_model.h>

namespace argos {

   /****************************************/
   /****************************************/

   CPiPuckRangefindersDefaultSensor::CPiPuckRangefindersDefaultSensor() :
      m_bShowRays(false),
      m_pcControllableEntity(nullptr) {}

   /****************************************/
   /****************************************/

   void CPiPuckRangefindersDefaultSensor::SetRobot(CComposableEntity& c_entity) {
      m_pcControllableEntity = &(c_entity.GetComponent<CControllableEntity>("controller"));
      /* allocate memory for the sensor interfaces */
      m_vecSimulatedInterfaces.reserve(m_mapSensorConfig.size());
      /* get the anchors for the sensor interfaces from m_mapSensorConfig */
      for(const std::pair<const UInt8, TConfiguration>& t_config : m_mapSensorConfig) {
         const char* pchAnchor = std::get<const char*>(t_config.second);
         SAnchor& sAnchor =
            c_entity.GetComponent<CEmbodiedEntity>("body").GetAnchor(pchAnchor);
         m_vecSimulatedInterfaces.emplace_back(t_config.first, sAnchor);
      }
   }

   /****************************************/
   /****************************************/
   
   void CPiPuckRangefindersDefaultSensor::Init(TConfigurationNode& t_tree) {
      try {
         CCI_PiPuckRangefindersSensor::Init(t_tree);
         GetNodeAttributeOrDefault(t_tree, "show_rays", m_bShowRays, m_bShowRays);
      }
      catch(CARGoSException& ex) {
         THROW_ARGOSEXCEPTION_NESTED("Initialization error in the Pi-Puck rangefinders sensor.", ex);
      }
   }
  
   /****************************************/
   /****************************************/
   
   void CPiPuckRangefindersDefaultSensor::Update() {
      /* buffers */
      CRay3 cSensorRay;
      CVector3 cRayStart, cRayEnd;
      SEmbodiedEntityIntersectionItem sIntersection;
      /* go through the sensors */
      for(SSimulatedInterface& s_interface : m_vecSimulatedInterfaces) {
         cRayStart = std::get<CVector3>(s_interface.Configuration);
         cRayStart.Rotate(s_interface.Anchor.Orientation);
         cRayStart += s_interface.Anchor.Position;
         cRayEnd = CVector3::Z * std::get<Real>(s_interface.Configuration);
         cRayEnd.Rotate(std::get<CQuaternion>(s_interface.Configuration));
         cRayEnd.Rotate(s_interface.Anchor.Orientation);
         cRayEnd += cRayStart;
         cSensorRay.Set(cRayStart,cRayEnd);
         /* Get the closest intersection */
         if(GetClosestEmbodiedEntityIntersectedByRay(sIntersection, cSensorRay)) {
            /* There is an intersection */
            if(m_bShowRays) {
               m_pcControllableEntity->AddIntersectionPoint(cSensorRay, sIntersection.TOnRay);
               m_pcControllableEntity->AddCheckedRay(true, cSensorRay);
            }
            s_interface.Reading = 
               ConvertToMeters(cSensorRay.GetDistance(sIntersection.TOnRay));
         }
         else {
            /* No intersection */
            s_interface.Reading = std::get<Real>(s_interface.Configuration);
            if(m_bShowRays) {
               m_pcControllableEntity->AddCheckedRay(false, cSensorRay);
            }
         }
      }
   }

   /****************************************/
   /****************************************/
   
   void CPiPuckRangefindersDefaultSensor::Reset() {
      for(SSimulatedInterface& s_interface : m_vecSimulatedInterfaces) {
         s_interface.Reading = std::get<Real>(s_interface.Configuration);
      }
   }
   
   /****************************************/
   /****************************************/

   void CPiPuckRangefindersDefaultSensor::ForEachInterface(std::function<void(const SInterface&)> fn) {
      for(const SSimulatedInterface& s_interface : m_vecSimulatedInterfaces) {
         fn(s_interface);
      }
   }

   /****************************************/
   /****************************************/

   REGISTER_SENSOR(CPiPuckRangefindersDefaultSensor,
                  "pipuck_rangefinders", "default",
                  "Michael Allwright [allsey87@gmail.com]",
                  "1.0",
                  "The pipuck rangefinders sensor.",
                  "This sensor measures the distance to nearby obstacles.",
                  "Usable"
   );
   
}

   
